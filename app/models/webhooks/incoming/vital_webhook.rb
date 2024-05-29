class Webhooks::Incoming::VitalWebhook < ApplicationRecord
  include Webhooks::Incoming::Webhook
  include Rails.application.routes.url_helpers

  def verify_authenticity
    true # Because we're handling this at time of event
  end

  def process
    event = self.data
    event_type = event.dig('event_type')

    case event_type
    when 'labtest.order.created'
      handle_lab_test_order_change(event.dig('data'))
    when 'labtest.order.updated'
      handle_lab_test_order_change(event.dig('data'))
    when 'labtest.result.critical'
      handle_lab_test_result_critical(event.dig('data'))
    else
      Rails.logger.info "[VITAL_WEBHOOK] - Unhandled event type: #{event_type}"
    end

    return true
  end

  def handle_lab_test_order_change(data)
    lab_test_order = LabTestOrder.find_by(vital_order_id: data['id'])
    return unless lab_test_order

    status = data['status']
    lab_test_order.update!(status: status)

    events = data['events']
    sorted_events = events.sort_by { |event| event['created_at'] }
    most_recent_event = sorted_events.last
    detailed_status = most_recent_event['status'].split('.').last
    lab_test_order.update!(detailed_status: detailed_status)

    lab_test_type = data.dig('details', 'type')
    case lab_test_type
    when "walk_in_test"
      handle_walk_in_test_order_change(lab_test_order, detailed_status, data)
    when "testkit"
      log_message = "Test type: #{lab_test_type} is not currently supported. This should not happen in production."
      Rails.logger.info log_message
      Sentry.capture_message(log_message)
    when "at_home_phlebotomy"
      log_message = "Test type: #{lab_test_type} is not currently supported. This should not happen in production."
      Rails.logger.info log_message
      Sentry.capture_message(log_message)
    else
      log_message = "Test type: #{lab_test_type} is not currently supported. This should not happen in production."
      Rails.logger.info log_message
      Sentry.capture_message(log_message)
    end
  end

  def handle_walk_in_test_order_change(lab_test_order, status, data)
    case status
    when 'ordered'
      Rails.logger.info "LabTestOrder (#{lab_test_order.id}) has been ordered successfully with Vital."
    when 'requisition_created'
      Rails.logger.info "LabTestOrder (#{lab_test_order.id}) requisition form has been created."
      requisition_form_url = data['requisition_form_url']
      if requisition_form_url.present?
        Rails.logger.info "Saving requisition form PDF for LabTestOrder ##{lab_test_order.id}..."
        response = Faraday.get(requisition_form_url)
        pdf = response.body
        lab_test_order.requisition_form.attach(
          io: StringIO.new(pdf),
          filename: "lab_order_#{lab_test_order.id}_requisition_form.pdf",
          content_type: "application/pdf"
        )
        Rails.logger.info "LabTestOrder ##{lab_test_order.id} requisition form PDF has been saved."
      end

      LabTestOrdersMailer.with(lab_test_order_id: lab_test_order.id).lab_form_ready.deliver_later
      notification = UserNotification.create(
        user_id: lab_test_order.user_id,
        title: 'Lab Order Form Ready',
        body: 'Your recent lab test order is ready to be taken. Tap to view in the app.',
        notification_type: :lab_test_order_update,
        additional_data: {
          lab_test_order_id: lab_test_order.id,
        }
      )
      SendUserNotificationsJob.perform_later(lab_test_order.user_id, notification.id)
    when 'partial_results'
      Rails.logger.info "LabTestOrder (#{lab_test_order.id}) is with lab with partial results. Not doing anything."
    when 'completed'
      Rails.logger.info "LabTestOrder ##{lab_test_order.id} has been completed. Results should be ready."
      
      results = get_lab_results(lab_test_order, send_notification: true)
      return unless results.present?

      LabTestOrdersMailer.with(lab_test_order_id: lab_test_order.id).results_ready.deliver_later
      notification = UserNotification.create(
        user_id: lab_test_order.user_id,
        title: 'Lab Test Results Ready!',
        body: 'Your recent lab test results are available. Tap to view them in the app.',
        notification_type: :lab_test_order_update,
        additional_data: {
          lab_test_order_id: lab_test_order.id,
        }
      )
      SendUserNotificationsJob.perform_later(lab_test_order.user_id, notification.id)
    when 'sample_error'
      error_message = "LabTestOrder (#{id}) has failed with Vital."
      Rails.logger.error error_message
      Sentry.capture_message(error_message)
      AdminMailer.with(issue: error_message, context: {
        lab_test_order_id: lab_test_order.id,
        user_id: lab_test_order.user_id,
        status: status,
      }).order_issue.deliver_later
    when 'cancelled'
      Rails.logger.info "LabTestOrder (#{lab_test_order.id}) has been cancelled."
      LabTestOrdersMailer.with(lab_test_order_id: lab_test_order.id).order_cancelled.deliver_later
      notification = UserNotification.create(
        user_id: lab_test_order.user_id,
        title: 'Lab Test Order Cancelled',
        body: 'Your recent lab test order has been cancelled. If this was in error or you have any other questions, please reach out to support.',
        notification_type: :lab_test_order_update,
        additional_data: {
          lab_test_order_id: lab_test_order.id,
        }
      )
      SendUserNotificationsJob.perform_later(lab_test_order.user_id, notification.id)
    else
      log_message = "LabTestOrder (#{lab_test_order.id}) has unknown status: #{status}."
      Rails.logger.info log_message
      Sentry.capture_message(log_message)
    end
  end

  def handle_lab_test_result_critical(data)
    Rails.logger.info "Lab test result critical for order: #{data.dig('id')}. Not doing anything for now."
    lab_test_order = LabTestOrder.find_by(vital_order_id: data.dig('id'))
    return unless lab_test_order.present?

    results = get_lab_results(lab_test_order)
    return unless results.present?
  end

  private

  def get_lab_results(lab_test_order, send_notification: false)
    vital_result = Vital.get_lab_test_order_results(lab_test_order.vital_order_id)
    return nil unless vital_result.present?

    results_data = vital_result['results']
    results_metadata = vital_result['metadata']

    # Find or create lab results
    vital_results = VitalLabTestResult.find_or_initialize_by(user_id: lab_test_order.user_id, vital_order_id: lab_test_order.vital_order_id)
    vital_results.results_data = results_data
    vital_results.date_reported = results_metadata['date_reported']
    vital_results.date_received = results_metadata['date_received']
    vital_results.date_collected = results_metadata['date_collected']
    vital_results.specimen_number = results_metadata['specimen_number']
    vital_results.status = results_metadata['status']
    vital_results.interpretation = results_metadata['interpretation']
    vital_results.save!

    # Update Lab Test Order
    lab_test_order.update!(
      results_status: results_metadata['status'], 
      results_reported_at: results_metadata['date_reported'], 
      results_collected_at: results_metadata['date_collected']
    )

    return nil unless results_data.present?

    new_lab_result_ids = []

    results_data.each do |result|
      lab_result, is_new = LabResult.create_from_vital_result(lab_test_order.user_id, result, lab_test_order)
      return unless lab_result.present?
      new_lab_result_ids << lab_result.id if is_new && lab_result.present?
    end

    pdf = Vital.get_lab_test_order_results_pdf(lab_test_order.vital_order_id)
    if pdf.present?
      Rails.logger.info "Saving results PDF for LabTestOrder ##{lab_test_order.id}..."
      lab_test_order.results_pdf.attach(
        io: StringIO.new(pdf),
        filename: "lab_order_#{lab_test_order.id}_results.pdf",
        content_type: "application/pdf"
      )
      Rails.logger.info "LabTestOrder ##{lab_test_order.id} results PDF has been saved."
    end

    if new_lab_result_ids.any?
      Rails.logger.info("#{new_lab_result_ids.count} new lab results from Vital")
      GenerateLabResultsSummaryJob.perform_later(lab_test_order.user_id)
    end
  end
end