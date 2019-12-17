itunes-connect-slack
--------------------

These scripts fetch app info directly from App Store Connect and posts changes in Slack as a bot. Since ASC doesn't provide event webhooks, these scripts use polling with the help of Fastlane's [Spaceship](https://github.com/fastlane/fastlane/tree/master/spaceship).

![](https://raw.githubusercontent.com/erikvillegas/itunes-connect-slack/master/example.png)

# Set up

### Environment Variables

These scripts read specific values from the bash environment. Be sure to set these to the appropriate values:
```bash
export BOT_API_TOKEN="xoxb-asdfasdfasfasdfasdfsd" # The API Token for your bot, provided by Slack
export itc_username="email@email.com" # The email you use to log into iTunes Connect
export bundle_id="com.best.app" # The bundle ID of the app you want these scripts to check
export SLACK_CHANNEL="channel_name" # The Slack channel to post to
```

### Install gems
```bash
bundle install
```

### Store your App Store Connect password
You can use Fastlane's [CredentialsManager](https://github.com/fastlane/fastlane/tree/master/credentials_manager) to store your password. Enter this command and it will prompt you for your password:
```bash
fastlane fastlane-credentials add --username itc_username@example.com
```

### Running the scripts
```bash
ruby poll-itc.rb
```

# Files

### get-app-status.rb
Ruby script that uses Spaceship to connect to iTunes Connect. It then stdouts a JSON blob with your app info. It only looks for apps that aren't yet live.

### poll-itc.rb
Ruby script to invoke the get-app-status.rb at certain intervals. It uses a key/value store to check for changes, and then invokes `post-update.rb`.

### post-update.rb
Ruby script that uses Slack's Ruby SDK to send a message as a bot. It also calculates the number of hours since submission.
