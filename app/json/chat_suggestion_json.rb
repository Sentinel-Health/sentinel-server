class ChatSuggestionJson
  def initialize(chat_suggestion)
    @chat_suggestion = chat_suggestion
  end

  def call(options=nil)
    return to_json(@chat_suggestion, options) unless @chat_suggestion.respond_to?(:each)
    @chat_suggestion.map { |chat_suggestion| to_json(chat_suggestion, options) }
  end

  private

  def to_json(chat_suggestion, options)
    return nil unless chat_suggestion
    Rails.cache.fetch("json/v1.0/#{chat_suggestion.cache_key_with_version}") do
      {
        id: chat_suggestion.id,
        title: chat_suggestion.title,
        description: chat_suggestion.description,
        prompt: chat_suggestion.prompt,
      }
    end
  end
end