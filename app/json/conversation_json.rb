class ConversationJson
  def initialize(conversation)
    @conversation = conversation
  end

  def call(options=nil)
    return to_json(@conversation, options) unless @conversation.respond_to?(:each)
    @conversation.map { |conversation| to_json(conversation, options) }
  end

  private

  def to_json(conversation, options)
    return nil unless conversation
    Rails.cache.fetch("json/v1.0/#{conversation.cache_key_with_version}") do
      {
        id: conversation.id,
        title: conversation.title,
        messages: conversation.messages.order(created_at: :desc).map { |message|
          MessageJson.new(message).call
        },
        lastActivityAt: conversation.last_activity_at,
        createdAt: conversation.created_at,
        updatedAt: conversation.updated_at,
      }
    end
  end
end