class ConditionHistoryJson
  def initialize(condition_history)
    @condition_history = condition_history
  end

  def call(options=nil)
    return to_json(@condition_history, options) unless @condition_history.respond_to?(:each)
    @condition_history.map { |condition_history| to_json(condition_history, options) }
  end

  private

  def to_json(condition_history, options)
    return nil unless condition_history
    Rails.cache.fetch("json/v1.0/#{condition_history.cache_key_with_version}") do
      {
        id: condition_history.id,
        name: condition_history.name,
        status: condition_history.status,
        source: condition_history.source,
        recordedOn: condition_history.recorded_on,
        recordedBy: condition_history.recorded_by,
        createdAt: condition_history.created_at,
        updatedAt: condition_history.updated_at,
      }
    end
  end
end