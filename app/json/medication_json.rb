class MedicationJson
  def initialize(medication)
    @medication = medication
  end

  def call(options=nil)
    return to_json(@medication, options) unless @medication.respond_to?(:each)
    @medication.map { |medication| to_json(medication, options) }
  end

  private

  def to_json(medication, options)
    return nil unless medication
    Rails.cache.fetch("json/v1.1/#{medication.cache_key_with_version}") do
      {
        id: medication.id,
        name: medication.name,
        status: medication.status,
        source: medication.source,
        isArchived: medication.is_archived,
        dosageInstructions: medication.dosage_instructions,
        authoredOn: medication.authored_on,
        authoredBy: medication.authored_by,
        createdAt: medication.created_at,
        updatedAt: medication.updated_at,
      }
    end
  end
end