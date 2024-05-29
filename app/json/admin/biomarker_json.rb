class Admin::BiomarkerJson
  def initialize(biomarker)
    @biomarker = biomarker
  end

  def call(options=nil)
    return to_json(@biomarker, options) unless @biomarker.respond_to?(:each)
    @biomarker.map { |biomarker| to_json(biomarker, options) }
  end

  private

  def to_json(biomarker, options)
    return nil unless biomarker
    Rails.cache.fetch("json/admin/v1.0/biomarker/#{biomarker.cache_key_with_version}") do
      {
        id: biomarker.id,
        name: biomarker.name,
        description: biomarker.description,
        alternative_names: biomarker.alternative_names,
        biomarker_subcategory: Admin::BiomarkerSubcategoryJson.new(biomarker.biomarker_subcategory).call,
        created_at: biomarker.created_at,
        updated_at: biomarker.updated_at,
      }
    end
  end
end