class HealthInsightJson
  def initialize(health_insight)
    @health_insight = health_insight
  end

  def call(options=nil)
    return to_json(@health_insight, options) unless @health_insight.respond_to?(:each)
    @health_insight.map { |health_insight| to_json(health_insight, options) }
  end

  private

  def to_json(health_insight, options)
    return nil unless health_insight
    Rails.cache.fetch("json/v1.0/#{health_insight.cache_key_with_version}") do
      {
        id: health_insight.id,
        category: health_insight.category,
        shortSummary: health_insight.insights.dig("short_summary"),
        suggestions: suggestions_json(health_insight.insights.dig("suggestions")),
      }
    end
  end

  def suggestions_json(suggestions)
    return nil unless suggestions
    suggestions.map do |suggestion|
      {
        suggestion: suggestion["suggestion"],
        chatPrompt: suggestion["chat_prompt"]
      }
    end
  end
end