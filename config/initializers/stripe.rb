require 'stripe'
Stripe.api_key = Rails.application.credentials.dig(:stripe, :secret_key)