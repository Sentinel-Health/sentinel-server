class Webhooks::Incoming::StripeWebhooksController < Webhooks::Incoming::BaseController
  def handle_event
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    event = nil

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, Rails.application.credentials.dig(:stripe, :webhook_secret)
      )
      Webhooks::Incoming::StripeWebhook.create(data: JSON.parse(event)).process_async
    rescue JSON::ParserError => e
      # Invalid payload
      status 400
      return
    rescue Stripe::SignatureVerificationError => e
      # Invalid signature
      status 400
      return
    end
    render json: {status: :ok}, status: :created
  end
end
