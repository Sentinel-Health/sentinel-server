class LabTestOrder < ApplicationRecord
  belongs_to :user, touch: true
  belongs_to :lab_test

  has_one_attached :results_pdf
  has_one_attached :requisition_form

  has_many :lab_results, dependent: :destroy

  enum status: {
    received: 'received',
    collecting_sample: 'collecting_sample',
    sample_with_lab: 'sample_with_lab',
    completed: 'completed',
    cancelled: 'cancelled',
    failed: 'failed',
  }

  enum detailed_status: {
    ordered: 'ordered',
    requisition_created: 'requisition_created',
    appointment_scheduled: 'appointment_scheduled',
    draw_completed: 'draw_completed',
    appointment_cancelled: 'appointment_cancelled',
    partial_results: 'partial_results',
    completed: 'completed',
    cancelled: 'cancelled',
    sample_error: 'sample_error',

    # Additional testkit statuses
    awaiting_registration: 'awaiting_registration',
    testkit_registered: 'testkit_registered',
    transit_customer: 'transit_customer',
    out_for_delivery: 'out_for_delivery',
    with_customer: 'with_customer',
    transit_lab: 'transit_lab',
    delivered_to_lab: 'delivered_to_lab',
    failure_to_deliver_to_customer: 'failure_to_deliver_to_customer',
    failure_to_deliver_to_lab: 'failure_to_deliver_to_lab',
    lost: 'lost',
    do_not_process: 'do_not_process',
  }, _prefix: :detailed # Needed since some of these conflict with the main status enum

  attribute :results_status, :string, default: 'final'
  enum results_status: {
    partial: 'partial',
    final: 'final'
  }, _prefix: :results

  before_create :set_order_number
  after_create :log_creation_event

  scope :active, -> { where(status: %i[received collecting_sample sample_with_lab]) }
  scope :completed, -> { where(status: :completed) }
  scope :active_or_completed, -> { where(status: %i[received collecting_sample sample_with_lab completed]) }
  scope :active_or_not_viewed, -> { active_or_completed.where(results_have_been_viewed: false) }

  def additional_info
    case lab_test.collection_method
    when "walk_in_test"
      case detailed_status
      when "ordered"
        """We've received your order and are getting your lab form ready. You'll receive an email from us once it is ready with the lab form attached. You'll also be able to find the form here."""
      when "requisition_created"
        """Your lab test order has been processed and is ready to be taken. If you haven't already done so, you can book an appointment for your test by going to [#{lab_test.lab.name}'s website](#{lab_test.lab.appointment_url}). You can only get this lab done at #{lab_test.lab.name}. 
        
If you are asked about payment information or any other financial information when trying to book an appointment, choose \"I have already paid or someone else is responsible\".
        
When you go to #{lab_test.lab.name}, bring the order form (electronically or printed out) and a Photo ID.#{lab_test.is_fasting_required ? "\n\n**IMPORTANT:** #{lab_test.fasting_instructions}" : "\n\nYou do not need to fast for this test."}#{lab_test.has_additional_preparation_instructions ? "\n\n**Additional Note:** #{lab_test.additional_preparation_instructions}" : ''}"""
      when "partial_results"
        """The lab has received your sample and is currently processing it. We'll let you know when all of your results are ready."""
      when "completed"
        """Your results are ready! You can now view them #{results_pdf.attached? ? 'in PDF form or ' : ''}in the app. 

All results that have available biomarkers will also appear in your biomarkers breakdown in the app."""
      when "cancelled"
        "Your order has been cancelled. If this was done in error, please reach out to support."
      when "sample_error"
        "There was a problem with your sample. Please reach out to support to find out more."
      else
        nil
      end
    # Not yet supported
    when "testkit"
      case detailed_status
      when "ordered"
        nil
      when "awaiting_registration"
        nil
      when "testkit_registered"
        nil
      when "requisition_created"
        nil
      when "transit_customer"
        nil
      when "out_for_delivery"
        nil
      when "with_customer"
        nil
      when "transit_lab"
        nil
      when "delivered_to_lab"
        nil
      when "completed"
        nil
      when "failure_to_deliver_to_customer"
        nil
      when "failure_to_deliver_to_lab"
        nil
      when "sample_error"
        nil
      when "lost"
        nil
      when "cancelled"
        nil
      when "do_not_process"
        nil
      else
        nil
      end
    # Not yet supported
    when "at_home_phlebotomy"
      case detailed_status
      when "ordered"
        nil
      when "requisition_created"
        nil
      when "appointment_scheduled"
        nil
      when "draw_completed"
        nil
      when "appointment_cancelled"
        nil
      when "partial_results"
        nil
      when "completed"
        nil
      when "cancelled"
        nil
      else
        nil
      end
    end
  end

  private 

  def set_order_number
    begin
      Retriable.retriable(on: [ActiveRecord::RecordNotUnique, ActiveRecord::Deadlocked], tries: 5) do
        last_number = LabTestOrder.maximum(:order_number) || 1000
        self.order_number = last_number + 1
      end
    rescue => e
      Rails.logger.error "Failed to assign a unique order_number to LabTestOrder #{id}."
      Sentry.capture_exception(e)
      AdminMailer.with(error: e.message, context: {
        file_location: "lab_test_order.rb",
        function_name: "set_order_number",
      }).critical_error.deliver_later
    end
  end

  def log_creation_event
    Analytics.track({
      user_id: user.id,
      event_type: 'Order Completed',
      event_properties: {
        orderType: 'lab_test',
        orderId: self.id,
        product: self.lab_test.name,
        amount: self.amount,
        currency: self.currency,
      }
    })
  end
end
