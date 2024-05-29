class Admin::BiomarkerCategoryJson
  def initialize(category)
    @category = category
  end

  def call(options=nil)
    return to_json(@category, options) unless @category.respond_to?(:each)
    @category.map { |category| to_json(category, options) }
  end

  private

  def to_json(category, options)
    return nil unless category
    Rails.cache.fetch("json/admin/v1.0/biomarker_category/#{category.cache_key_with_version}") do
      {
        id: category.id,
        name: category.name,
        description: category.description,
        created_at: category.created_at,
        updated_at: category.updated_at,
      }
    end
  end
end