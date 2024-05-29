class Admin::LabTestOrderJson
  include ActionView::Helpers::NumberHelper
  include Rails.application.routes.url_helpers

  def initialize(lab_test_order)
    @lab_test_order = lab_test_order
  end

  def call(options=nil)
    return to_json(@lab_test_order, options) unless @lab_test_order.respond_to?(:each)
    @lab_test_order.map { |lab_test_order| to_json(lab_test_order, options) }
  end

  private

  def to_json(lab_test_order, options)
    return nil unless lab_test_order
    Rails.cache.fetch("json/admin/v1.0/#{lab_test_order.cache_key_with_version}") do
      {
        id: lab_test_order.id,
        order_number: lab_test_order.order_number,
        status: lab_test_order.status,
        amount: lab_test_order.amount,
        currency: lab_test_order.currency,
        detailed_status: lab_test_order.detailed_status,
        results_have_been_viewed: lab_test_order.results_have_been_viewed,
        requisition_form_url: lab_test_order.requisition_form.attached? ? rails_blob_url(lab_test_order.requisition_form, disposition: "attachment") : nil,
        results_pdf_url: lab_test_order.results_pdf.attached? ? rails_blob_url(lab_test_order.results_pdf, disposition: "attachment") : nil,
        additional_info: lab_test_order.additional_info,
        lab_test: Admin::LabTestJson.new(lab_test_order.lab_test).call,
        user: Admin::UserJson.new(lab_test_order.user).call,
        results_status: lab_test_order.results_status,
        results_reported_at: lab_test_order.results_reported_at,
        results_collected_at: lab_test_order.results_collected_at,
        stripe_checkout_session_id: lab_test_order.stripe_checkout_session_id,
        created_at: lab_test_order.created_at,
        updated_at: lab_test_order.updated_at,
      }
    end
  end
end