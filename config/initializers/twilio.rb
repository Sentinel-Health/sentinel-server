require 'twilio-ruby'

if Rails.application.credentials.twilio
  $twilio = Twilio::REST::Client.new(
    Rails.application.credentials.dig(:twilio, :account_sid), 
    Rails.application.credentials.dig(:twilio, :auth_token)
  )
else
  Rails.logger.error("Twilio credentials not found!")
end