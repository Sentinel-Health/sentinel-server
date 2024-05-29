class ConditionJson
  def initialize(condition)
    @condition = condition
  end

  def call(options=nil)
    return to_json(@condition, options) unless @condition.respond_to?(:each)
    @condition.map { |condition| to_json(condition, options) }
  end

  private

  def to_json(condition, options)
    return nil unless condition
    Rails.cache.fetch("json/v1.1/#{condition.cache_key_with_version}") do
      {
        id: condition.id,
        name: condition.name,
        status: condition.status,
        isArchived: condition.is_archived,
        createdAt: condition.created_at,
        updatedAt: condition.updated_at,
        history: condition.condition_histories.order(recorded_on: :desc).map { |history| ConditionHistoryJson.new(history).call(options) }
      }
    end
  end
end