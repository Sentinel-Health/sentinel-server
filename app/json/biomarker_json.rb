class BiomarkerJson
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
    Rails.cache.fetch("json/v1.2/biomarker/#{biomarker.cache_key_with_version}") do
      {
        id: biomarker.id,
        name: biomarker.name,
        description: biomarker.description,
        unit: biomarker.unit,
        alternativeNames: biomarker.alternative_names,
        category: biomarker.biomarker_category.name,
        subcategory: biomarker.biomarker_subcategory.name,
      }
    end
  end
end