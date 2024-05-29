class AllergyJson
  def initialize(allergy)
    @allergy = allergy
  end

  def call(options=nil)
    return to_json(@allergy, options) unless @allergy.respond_to?(:each)
    @allergy.map { |allergy| to_json(allergy, options) }
  end

  private

  def to_json(allergy, options)
    return nil unless allergy
    Rails.cache.fetch("json/v1.1/#{allergy.cache_key_with_version}") do
      {
        id: allergy.id,
        name: allergy.name,
        status: allergy.status,
        source: allergy.source,
        isArchived: allergy.is_archived,
        recordedOn: allergy.recorded_on,
        createdAt: allergy.created_at,
        updatedAt: allergy.updated_at,
      }
    end
  end
end