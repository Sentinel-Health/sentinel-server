class LabTestJson
  include ActionView::Helpers::NumberHelper
  include Rails.application.routes.url_helpers

  def initialize(lab_test)
    @lab_test = lab_test
  end

  def call(options=nil)
    return to_json(@lab_test, options) unless @lab_test.respond_to?(:each)
    @lab_test.map { |lab_test| to_json(lab_test, options) }
  end

  private

  def to_json(lab_test, options)
    return nil unless lab_test
    Rails.cache.fetch("json/v1.4/#{lab_test.cache_key_with_version}") do
      {
        id: lab_test.id,
        imageUrl: lab_test.image.attached? ? rails_blob_url(lab_test.image, disposition: "attachment") : nil,
        name: lab_test.name,
        tags: lab_test.tag_list,
        shortDescription: lab_test.short_description,
        markdownDescription: lab_test.markdown_description,
        category: lab_test.category,
        collectionInstructions: lab_test.collection_instructions,
        afterOrderInstructions: lab_test.after_order_instructions,
        appointmentUrl: lab_test.appointment_booking_url,
        isFastingRequired: lab_test.is_fasting_required,
        fastingInstructions: lab_test.is_fasting_required ? lab_test.fasting_instructions : nil,
        hasAdditionalPreparationInstructions: lab_test.has_additional_preparation_instructions,
        additionalPreparationInstructions: lab_test.has_additional_preparation_instructions ? lab_test.additional_preparation_instructions : nil,
        labName: lab_test.lab.name,
        price: number_to_currency(lab_test.price, precision: 0),
        createdAt: lab_test.created_at,
        updatedAt: lab_test.updated_at,
        biomarkers: lab_test.biomarkers.order(:name).map { |biomarker| BiomarkerJson.new(biomarker).call },
        order: lab_test.order
      }
    end
  end
end