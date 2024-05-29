class ApplicationMailer < ActionMailer::Base
  default from: "Sentinel#{Rails.env == "production" ? "" : "_#{Rails.env}"} <notifications@#{Rails.application.credentials.domain}>"
  layout "mailer"
end
