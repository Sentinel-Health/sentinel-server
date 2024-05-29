class Admin::LabJson
  def initialize(lab)
    @lab = lab
  end

  def call(options=nil)
    return to_json(@lab, options) unless @lab.respond_to?(:each)
    @lab.map { |lab| to_json(lab, options) }
  end

  private

  def to_json(lab, options)
    return nil unless lab
    Rails.cache.fetch("json/admin/v1.0/#{lab.cache_key_with_version}") do
      {
        name: lab.name,
        address_line_1: lab.address_line_1,
        address_line_2: lab.address_line_2,
        city: lab.city,
        state: lab.state,
        zip_code: lab.zip_code,
        country: lab.country,
        phone_number: lab.phone_number,
        support_email: lab.support_email,
        website: lab.website,
        appointment_url: lab.appointment_url,
        collection_methods: lab.collection_methods,
        sample_types: lab.sample_types,
        vital_lab_id: lab.vital_lab_id,
        vital_lab_slug: lab.vital_lab_slug,
        created_at: lab.created_at,
        updated_at: lab.updated_at,
      }
    end
  end
end