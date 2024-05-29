class AdminMailer < ApplicationMailer
  default from: "Sentinel#{Rails.env == "production" ? "" : "_#{Rails.env}"} Admin <admin.notifications@#{Rails.application.credentials.domain}>"
  default to: "admins@sentinelhealth.co"

  def critical_error
    @error = params[:error]
    @context = params[:context]
    mail(
      subject: "[CRITICAL ERROR]: #{@error}"
    )
  end

  def lab_test_order_issue
    @issue = params[:issue]
    @context = params[:context]
    mail(
      to: "support@#{Rails.application.credentials.domain}",
      subject: "Lab Test Order Issue"
    )
  end

  def biomarker_not_found
    @name = params[:name]
    @context = params[:context]
    mail(
      subject: "Biomarker missing for #{@name}"
    )
  end

  def missing_result_data
    @data_source = params[:data_source]
    @context = params[:context]
    mail(
      subject: "Missing result data"
    )
  end
end
