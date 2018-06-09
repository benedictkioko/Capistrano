module Slackistrano
  class SmallDevelopersTwoBit < Messaging::Base

    # Send failed message to #ops. Send all other messages to default channels.
    # The #ops channel must exist prior.
    def channels_for(action)
      super
    end

    # Suppress updating message.
    def payload_for_updating
      nil
    end

    # Suppress reverting message.
    def payload_for_reverting
      nil
    end

    # Fancy updated message.
    # See https://api.slack.com/docs/message-attachments
    def payload_for_updated
      {
        attachments: [{
                        color: 'good',
                        title: 'Site Deployed :boom::bangbang:',
                        fields: [{
                                   title: 'Environment',
                                   value: stage,
                                   short: true
                                 }, {
                                   title: 'Branch',
                                   value: branch,
                                   short: true
                                 }, {
                                   title: 'Deployer',
                                   value: deployer,
                                   short: true
                                 }, {
                                   title: 'Time',
                                   value: elapsed_time,
                                   short: true
                                 }],
                        fallback: super[:text]
                      }]
      }
    end

    # Default reverted message.  Alternatively simply do not redefine this
    # method.
    def payload_for_reverted
      super
    end

    # Slightly tweaked failed message.
    # See https://api.slack.com/docs/message-formatting
    def payload_for_failed
      payload = super
      payload[:text] = "OMG! :fire: #{payload[:text]}"
      payload
    end

    # Override the deployer helper to pull the full name from the password file.
    # See https://github.com/phallstrom/slackistrano/blob/master/lib/slackistrano/messaging/helpers.rb
    def deployer
      pwname = Etc.getpwnam(Etc.getlogin)
      fname = pwname.gecos.split(/,/).first if pwname
      fname || ENV['USER'] || ENV['USERNAME']
      # Etc.getpwnam(Etc.getlogin).gecos.split(/,/).first
    end
  end
end
