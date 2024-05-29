class Admin::BiomarkerSubcategoryJson
  def initialize(subcategory)
    @subcategory = subcategory
  end

  def call(options=nil)
    return to_json(@subcategory, options) unless @subcategory.respond_to?(:each)
    @subcategory.map { |subcategory| to_json(subcategory, options) }
  end

  private

  def to_json(subcategory, options)
    return nil unless subcategory
    Rails.cache.fetch("json/admin/v1.0/biomarker_subcategory/#{subcategory.cache_key_with_version}") do
      {
        id: subcategory.id,
        name: subcategory.name,
        description: subcategory.description,
        biomarker_category: Admin::BiomarkerCategoryJson.new(subcategory.biomarker_category).call,
        created_at: subcategory.created_at,
        updated_at: subcategory.updated_at,
      }
    end
  end
end