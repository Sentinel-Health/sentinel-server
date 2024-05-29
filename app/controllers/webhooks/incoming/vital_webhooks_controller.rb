class Webhooks::Incoming::VitalWebhooksController < Webhooks::Incoming::BaseController
  def handle_event
    header_token = request.headers['X-Vital-Webhook-Secret'] || ''
    secret_token = Rails.application.credentials.dig(:vital, :webhook_secret)

    unless ActiveSupport::SecurityUtils.secure_compare(header_token, secret_token)
      render json: {error: :unauthorized }, status: :unauthorized
      return
    end

    begin
      event = request.body.read
      Webhooks::Incoming::VitalWebhook.create(data: JSON.parse(event)).process_async
    rescue JSON::ParserError => e
      # Invalid payload
      render json: {error: :bad_request}, status: :bad_request
      return
    end

    render json: {status: :ok}, status: :created
  end
end
