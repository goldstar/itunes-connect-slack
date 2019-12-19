require 'spaceship'
require 'json'

class GetAppStatus
	def self.getVersionInfo(app)
		editVersionInfo = app.edit_version
		liveVersionInfo = app.live_version

		version = Hash.new

		if editVersionInfo
			version["editVersion"] = {
					"name" => app.name,
					"version" => editVersionInfo.version,
					"status" => editVersionInfo.app_status,
					"appId" => app.apple_id,
					"iconUrl" => app.app_icon_preview_url
			}
		end

		if liveVersionInfo
			version["liveVersion"] = {
					"name" => app.name,
					"version" => liveVersionInfo.version,
					"status" => liveVersionInfo.app_status,
					"appId" => app.apple_id,
					"iconUrl" => app.app_icon_preview_url
			}
		end

		version
	end

	def self.getAppVersionFrom(bundle_id)
		versions = []

		# all apps
		apps = []
		if (bundle_id)
			app = Spaceship::Tunes::Application.find(bundle_id)
			apps.push(app)
		else
			apps = Spaceship::Tunes::Application.all
		end

		for app in apps do
			version = getVersionInfo(app)
			versions.push(version)
		end

		versions
	end

	def self.getAppVersionInfo
		# Constants
		itc_username = ENV['itc_username']
		itc_password = ENV['itc_password']
		#split team_id
		itc_team_id_array = ENV['itc_team_id'].to_s.split(",")
		bundle_id = ENV['bundle_id']

		if (!itc_username)
			puts "did not find username"
			exit
		end

		if (itc_password)
			Spaceship::Tunes.login(itc_username, itc_password)
		else
			Spaceship::Tunes.login(itc_username)
		end

		getAppVersionFrom(bundle_id)
		# all json data
		#versions = []

#add for the team_ids
#test if itc_team doesnt exists

# if(itc_team_id_array)
# 	for itc_team_id in itc_team_id_array
# 		if (itc_team_id)
# 			Spaceship::Tunes.client.team_id = itc_team_id
# 		end
# 		versions += getAppVersionFrom(bundle_id)
# 	end
# else
#		versions += getAppVersionFrom(bundle_id)
# end

		#puts JSON.dump versions
	end
end



