class ProcedureJson
  def initialize(procedure)
    @procedure = procedure
  end

  def call(options=nil)
    return to_json(@procedure, options) unless @procedure.respond_to?(:each)
    @procedure.map { |procedure| to_json(procedure, options) }
  end

  private

  def to_json(procedure, options)
    return nil unless procedure
    Rails.cache.fetch("json/v1.1/#{procedure.cache_key_with_version}") do
      {
        id: procedure.id,
        name: procedure.name,
        status: procedure.status,
        source: procedure.source,
        performedOn: procedure.performed_on.to_time,
        isArchived: procedure.is_archived,
        createdAt: procedure.created_at,
        updatedAt: procedure.updated_at,
      }
    end
  end
end