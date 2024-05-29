if Rails.application.credentials.openai
  OpenAI.configure do |config|
    config.access_token =  Rails.application.credentials.openai[:api_key]
    config.organization_id = Rails.application.credentials.openai[:org_id]
  end
  $openai = OpenAI::Client.new
else
  Rails.logger.error("OpenAI credentials not found!")
end