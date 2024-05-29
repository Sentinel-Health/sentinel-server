class Webhooks::Incoming::StripeWebhook < ApplicationRecord
  include Webhooks::Incoming::Webhook
  include Rails.application.routes.url_helpers

  def verify_authenticity
    true # Because we're handling this at time of event
  end

  def process
    event = self.data
    event_type = event.dig('type')

    case event_type
    when 'checkout.session.completed'
      handle_checkout_session_completed(event.dig('data', 'object'))
    else
      Rails.logger.info "[STRIPE_WEBHOOK] - Unhandled event type: #{event_type}"
    end

    return true
  end

  def handle_checkout_session_completed(checkout_session)
    # Only create a lab test order if the payment was successful
    if checkout_session.dig('mode') == 'payment' && checkout_session.dig('payment_status') == 'paid'
      user = User.find_by(stripe_customer_id: checkout_session.dig('customer'))
      if !user.present?
        # This shouldn't happen but it can in dev/staging environments potentially
        # In the future, we might want to handle this case by creating a new user and firing off an onboarding flow before continuing on with the order
        log_message = "User not found for stripe_customer_id: #{checkout_session.dig('customer')}"
        Rails.logger.info "[STRIPE_WEBHOOK] - #{log_message}"
        Sentry.capture_message(log_message) if defined?(Sentry)
        return
      end
      line_items_response = Stripe::Checkout::Session.list_line_items(checkout_session.dig('id'))
      line_items = JSON.parse(line_items_response)
      line_items.dig('data').each do |line_item|
        lab_test = LabTest.find_by(stripe_product_id: line_item.dig('price', 'product'))
        next unless lab_test
        
        Rails.logger.info "Initializing a lab test order for user: #{user.id}"
        lab_test_order = LabTestOrder.find_or_initialize_by(user: user, lab_test: lab_test, stripe_checkout_session_id: checkout_session.dig('id'))
        lab_test_order.amount = checkout_session.dig('amount_total').present? ? checkout_session.dig('amount_total') / 100.0 : 0.0
        lab_test_order.currency = checkout_session.dig('currency')
        lab_test_order.save!
        Rails.logger.info "Lab test order saved successfully for user: #{user.id}, order: #{lab_test_order.id}"
        
        if lab_test_order.vital_order_id.present?
          Rails.logger.info "Vital lab test order already exists for user: #{user.id}, order: #{lab_test_order.id}, skipping creation"
        else
          if user.vital_user_id.nil?
            Rails.logger.info "No Vital user exists for user: #{user.id}, creating one..."
            vital_user = Vital.create_user(user_id: user.id)
            user.update!(vital_user_id: vital_user.dig('user_id'))
            Rails.logger.info "Created a new Vital user for user: #{user.id}"
          else
            vital_user = Vital.get_user(user.vital_user_id)
            Rails.logger.info "Found an existing Vital user for user: #{user.id}"
          end
          user.reload
          raise "Failed to create or retrieve Vital user for user: #{user.id}" unless user.vital_user_id

          Rails.logger.info "Creating a new Vital lab test order for user: #{user.id}"
          vital_order = Vital.create_lab_test_order(
            user_id: user.vital_user_id,
            lab_test_id: lab_test.vital_lab_test_id,
            patient_details: {
              first_name: user.health_profile.try(:legal_first_name) || user.first_name,
              last_name: user.health_profile.try(:legal_last_name) || user.last_name,
              gender: user.health_profile.try(:sex),
              phone_number: user.phone_number,
              email: user.email,
              dob: user.health_profile.try(:dob).to_time.strftime('%Y-%m-%d'),
            },
            patient_address: {
              first_line: user.address_line_1,
              second_line: user.address_line_2,
              city: user.city,
              state: user.state,
              zip: user.zip_code,
              country: user.country || 'US'
            }
          )
          raise "Failed to create Vital lab test order for user: #{user.id}" unless vital_order.dig('order', 'id')
          Rails.logger.info "Created a new lab test order on Vital: #{vital_order.dig('order', 'id')} for user: #{user.id}"
          lab_test_order.update!(vital_order_id: vital_order.dig('order', 'id'))
        end
      end
    else
      log_message = "[STRIPE_WEBHOOK] - Unhandled checkout.session.completed mode: #{checkout_session.dig('mode')} and payment_status: #{checkout_session.dig('payment_status')} for session: #{checkout_session.dig('id')}"
      Rails.logger.info log_message
      Sentry.capture_message(log_message) if defined?(Sentry)
    end
  end
end
