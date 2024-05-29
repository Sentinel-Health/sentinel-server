class LabTestOrderJson
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
    Rails.cache.fetch("json/v1.1/#{lab_test_order.cache_key_with_version}") do
      {
        id: lab_test_order.id,
        orderNumber: lab_test_order.order_number,
        status: lab_test_order.status,
        amount: number_to_currency(lab_test_order.amount, precision: 0),
        detailedStatus: lab_test_order.detailed_status,
        resultsHaveBeenViewed: lab_test_order.results_have_been_viewed,
        requisitionFormUrl: lab_test_order.requisition_form.attached? ? rails_blob_url(lab_test_order.requisition_form, disposition: "attachment") : nil,
        resultsPDFUrl: lab_test_order.results_pdf.attached? ? rails_blob_url(lab_test_order.results_pdf, disposition: "attachment") : nil,
        additionalInfo: lab_test_order.additional_info,
        labTest: LabTestJson.new(lab_test_order.lab_test).call,
        resultsStatus: lab_test_order.results_status,
        resultsReportedAt: lab_test_order.results_reported_at,
        resultsCollectedAt: lab_test_order.results_collected_at,
        results: lab_test_order.lab_results.order(:name).map { |result| LabResultJson.new(result, :full).call },
        createdAt: lab_test_order.created_at,
        updatedAt: lab_test_order.updated_at,
      }
    end
  end
end