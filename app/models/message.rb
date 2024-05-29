class Message < ApplicationRecord
  belongs_to :conversation, touch: :last_activity_at

  has_many :feedback, class_name: 'ChatFeedback', dependent: :destroy

  after_create :vector_database_upsert, if: :user_or_assistant?
  after_update :vector_database_upsert, if: :user_or_assistant?
  after_destroy :remove_from_vector_database, if: :user_or_assistant?

  after_create :title_conversation, if: :first_user_message?

  def user_or_assistant?
    role == 'user' || role == 'assistant'
  end

  def first_user_message?
    role == 'user' && conversation.messages.where(role: 'user').count == 1
  end

  def title_conversation
    conversation.create_title
  end

  include VectorDbService
  def vector_metadata
    {
      message_id: self.id,
      user_id: self.conversation.user_id,
      conversation_id: self.conversation.id,
      role: self.role || "",
    }
  end

  def vector_database_upsert
    return if self.content.blank?
    save_in_vector_db("messages", id, self.content, vector_metadata)
  end

  def remove_from_vector_database
    delete_from_vector_db("messages", self.id)
  end

  def self.vector_database_batch_upsert
    vectors = []
    self.find_each(batch_size: 100) do |message|
      next if message.content.blank?
      vectors << {
        id: message.id,
        metadata: message.vector_metadata,
        values: VectorDbService.get_embedding(message.content)
      }

      if vectors.size >= 100
        batch_upsert_in_vector_db("messages", vectors)
        vectors.clear
      end
    end
  
    batch_upsert_in_vector_db("messages", vectors) unless vectors.empty?
  end

  def self.get_related_conversations(user_id, subject, offset = 0, filter = {}, k = 50)
    results = query_vector_db("messages", user_id, subject, offset, filter, k)

    # Map to store the highest score for each conversation
    highest_scores = {}

    results.each do |result|
      convo_id = result[:data][:conversation_id]
      score = result[:score]

      # Skip if the score is too low
      next if score < 0.35
  
      # Update the highest score for the conversation
      if highest_scores[convo_id].nil? || score > highest_scores[convo_id]
        highest_scores[convo_id] = score
      end
    end

    # Sort conversations by the highest score and take the top ones
    top_conversations = highest_scores.sort_by { |_id, score| -score }
                                      .first(k)
                                      .map(&:first)

    # Retrieve the Conversation objects, keeping the order
    conversations = Conversation.where(id: top_conversations).to_a
    conversations.sort_by! { |conversation| top_conversations.index(conversation.id) }
  end
end
