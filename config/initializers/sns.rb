if Rails.application.credentials.aws
  $sns = Aws::SNS::Client.new
else
  Rails.logger.error("AWS credentials not found!")
end