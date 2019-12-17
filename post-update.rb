require "slack"

class PostUpdate
  Slack.configure do |config|
    config.token = ENV['BOT_API_TOKEN']
  end

  def self.post_to_slack(app_info, submission_start_date)
    client = Slack::Web::Client.new
    message = "The status of your app *#{app_info["name"]}* has been changed to *#{app_info["status"]}*"
    attachment = self.slack_attachment(app_info, submission_start_date)
    params = {
        attachments: [attachment],
        channel: ENV["SLACK_CHANNEL"],
        text: message,
        username: "ios-update-bot",
        icon_emoji: ":iphone:"
    }
    puts "Posting to slack: #{params}"
    client.chat_postMessage(params)
  end

  def self.slack_attachment(app_info, submission_start_date)
    attachment = {
        fallback: "The status of your app #{app_info["name"]} has been changed to #{app_info["status"]}",
        color: self.color_for_status(app_info["status"]),
        title: "App Store Connect",
        author_name: app_info["name"],
        author_icon: app_info["iconUrl"],
        title_link: "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/ng/app/#{app_info["appId"]}",
        fields: [
            {
                title: "Version",
                value: app_info["version"],
                short: true
            },
            {
                title: "Status",
                value: app_info["status"],
                short: true
            }
        ],
        footer: "App Store Connect",
        footer_icon: "https://devimages.apple.com.edgekey.net/app-store/marketing/guidelines/images/app-store-icon.png",
        ts: Time.now.to_i
    }

    # Set elapsed time since "Waiting for Review" start
    if submission_start_date && app_info["status"] != "Prepare for Submission" && app_info["status"] != "Waiting for Review"
      elapsed_hours = (Time.now - Time.at(submission_start_date)) / 60
      attachment[:fields].push({
                                    title: "Elapsed Time",
                                    value: "#{elapsed_hours} hours",
                                    short: true
                                })
    end

    attachment
  end

  def self.color_for_status(status)
    infoColor = "#8e8e8e"
    warningColor = "#f4f124"
    successColor1 = "#1eb6fc"
    successColor2 = "#14ba40"
    failureColor = "#e0143d"
    colorMapping = {
        "Prepare for Submission": infoColor,
        "Waiting For Review": infoColor,
        "In Review": successColor1,
        "Pending Contract": warningColor,
        "Waiting For Export Compliance": warningColor,
        "Pending Developer Release": successColor2,
        "Processing for App Store": successColor2,
        "Pending Apple Release": successColor2,
        "Ready for Sale": successColor2,
        "Rejected": failureColor,
        "Metadata Rejected": failureColor,
        "Removed From Sale": failureColor,
        "Developer Rejected": failureColor,
        "Developer Removed From Sale": failureColor,
        "Invalid Binary": failureColor
    }
    colorMapping[status]
  end
end