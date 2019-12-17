itunes-connect-slack
--------------------

These scripts fetch app info directly from iTunes Connect and posts changes in Slack as a bot. Since iTC doesn't provide event webhooks, these scripts use polling with the help of Fastlane's [Spaceship](https://github.com/fastlane/fastlane/tree/master/spaceship).

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

### Install node modules
```bash
bundle install
npm install
```

### Store your iTunes Connect password
You can use Fastlane's [CredentialsManager](https://github.com/fastlane/fastlane/tree/master/credentials_manager) to store your password. Enter this command and it will prompt you for your password:
```bash
fastlane fastlane-credentials add --username itc_username@example.com
```

### Channel info
Set the specific channel you'd like the bot to post to in `post-update.js`. By default, it posts to `#apps`.

### Running the scripts
```bash
node poll-itc.js
```

# Files

### get-app-status.rb
Ruby script that uses Spaceship to connect to iTunes Connect. It then stdouts a JSON blob with your app info. It only looks for apps that aren't yet live.

### poll-itc.js
Node script to invoke the ruby script at certain intervals. It uses a key/value store to check for changes, and then invokes `post-update.js`.

### post-update.js
Node script that uses Slack's node.js SDK to send a message as a bot. It also calculates the number of hours since submission.
