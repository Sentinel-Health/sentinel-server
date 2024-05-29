class ImmunizationJson
  def initialize(immunization)
    @immunization = immunization
  end

  def call(options=nil)
    return to_json(@immunization, options) unless @immunization.respond_to?(:each)
    @immunization.map { |immunization| to_json(immunization, options) }
  end

  private

  def to_json(immunization, options)
    return nil unless immunization
    Rails.cache.fetch("json/v1.1/#{immunization.cache_key_with_version}") do
      {
        id: immunization.id,
        name: immunization.name,
        source: immunization.source,
        receivedOn: immunization.received_on.to_time,
        isArchived: immunization.is_archived,
        createdAt: immunization.created_at,
        updatedAt: immunization.updated_at,
      }
    end
  end
end