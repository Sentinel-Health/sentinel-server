require 'pinecone'

if Rails.application.credentials.pinecone
  Pinecone.configure do |config|
    config.api_key = Rails.application.credentials.dig(:pinecone, :api_key)
  end
  $pinecone = Pinecone::Client.new
else
    Rails.logger.error("Pinecone credentials not found!")
end