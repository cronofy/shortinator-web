Hatchet.configure do |config|
  config.level :info

  config.appenders << Hatchet::LoggerAppender.new do |appender|
    appender.logger = Logger.new(STDOUT)
  end

  hatchet.appenders << Hatchet::HipChatAppender.new do |hipchat|
    hipchat.formatter = Hatchet::HipChatEmoticonFormatter.new
    hipchat.level (ENV['HATCHET_HIPCHAT_LEVEL'] || 'WARN').downcase.to_sym
    hipchat.api_token = ENV['HATCHET_HIPCHAT_TOKEN']
    hipchat.room_id   = ENV['HATCHET_HIPCHAT_ROOM_ID']
    hipchat.name      = ENV['HATCHET_HIPCHAT_NAME']
  end if ENV['HATCHET_HIPCHAT_TOKEN']
end
