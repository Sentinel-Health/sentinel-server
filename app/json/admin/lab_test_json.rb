class Admin::LabTestJson
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
    Rails.cache.fetch("json/admin/v1.0/#{lab_test.cache_key_with_version}") do
      {
        id: lab_test.id,
        image_url: lab_test.image.attached? ? rails_blob_url(lab_test.image, disposition: "attachment") : nil,
        name: lab_test.name,
        tags: lab_test.tag_list.join(","),
        short_description: lab_test.short_description,
        markdown_description: lab_test.markdown_description,
        category: lab_test.category,
        collection_instructions: lab_test.collection_instructions,
        after_order_instructions: lab_test.after_order_instructions,
        appointment_url: lab_test.appointment_booking_url,
        is_fasting_required: lab_test.is_fasting_required,
        fasting_instructions: lab_test.is_fasting_required ? lab_test.fasting_instructions : nil,
        has_additional_preparation_instructions: lab_test.has_additional_preparation_instructions,
        additional_preparation_instructions: lab_test.has_additional_preparation_instructions ? lab_test.additional_preparation_instructions : nil,
        lab_name: lab_test.lab.name,
        created_at: lab_test.created_at,
        updated_at: lab_test.updated_at,
        biomarkers: lab_test.biomarkers.order(:name).map { |biomarker| Admin::BiomarkerJson.new(biomarker).call },
        order: lab_test.order,
        collection_method: lab_test.collection_method,
        status: lab_test.status,
        sample_type: lab_test.sample_type,
        price: lab_test.price,
        currency: lab_test.currency,
        vital_lab_test_id: lab_test.vital_lab_test_id,
        stripe_product_id: lab_test.stripe_product_id,
        has_biotin_interference_potential: lab_test.has_biotin_interference_potential,
      }
    end
  end
end