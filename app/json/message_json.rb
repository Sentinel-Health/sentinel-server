class MessageJson
  def initialize(message)
    @message = message
  end

  def call(options=nil)
    return to_json(@message, options) unless @message.respond_to?(:each)
    @message.map { |message| to_json(message, options) }
  end

  private

  def to_json(message, options)
    return nil unless message
    Rails.cache.fetch("json/v1.0/#{message.cache_key_with_version}") do
      {
        id: message.id,
        role: message.role,
        name: message.name,
        functionCall: message.function_call,
        content: message.content,
        toolCalls: message.tool_calls,
        toolCallId: message.tool_call_id,
        createdAt: message.created_at,
        updatedAt: message.updated_at,
      }
    end
  end
end