require './get-app-status.rb'
require './post-update.rb'
require './database.rb'

class PollItc
  def self.debug
    true
  end

  def self.check_app_status
    puts "Fetching latest app status..."
    versions = GetAppStatus.getAppVersionInfo
    for version in versions
      puts "Checking app status..."
      self._check_app_status(version)
    end
  end

  private

  def self._check_app_status(version)
    # Use the live version if edit version is unavailable
    current_app_info = version["editVersion"] || version["liveVersion"]
    puts "current_app_info: #{current_app_info}"

    app_info_key = "appInfo-#{current_app_info["appId"]}"
    submission_start_key = "submissionStart#{current_app_info["appId"]}"

    last_app_info = Database.get(app_info_key)
    if last_app_info.nil? || last_app_info["status"] != current_app_info["status"] || debug
      PostUpdate.post_to_slack(current_app_info, Database.get(submission_start_key))

      # Store submission start time
      if current_app_info["status"] == "Waiting for Review"
        Database.set(submission_start_key, DateTime.new)
      else
        if !current_app_info.nil?
          puts "Current status #{current_app_info["status"]} matches previous status. AppName: #{current_app_info["name"]}"
        else
          puts "Could not fetch app status"
        end
      end
    end

    # Store latest app info in database
    Database.set(app_info_key, current_app_info)
  end
end

PollItc.check_app_status