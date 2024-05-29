class ChatFeedback < ApplicationRecord
  belongs_to :user
  belongs_to :message

  enum feedback_type: {
    positive: 'positive',
    negative: 'negative',
  }

  scope :positive, -> { where(feedback_type: :positive) }
  scope :negative, -> { where(feedback_type: :negative) }

  def self.create_positive_feedback(user_id, message_id)
    self.create(user_id: user_id, message_id: message_id, feedback_type: :positive)
  end

  def self.create_negative_feedback(user_id, message_id)
    self.create(user_id: user_id, message_id: message_id, feedback_type: :negative)
  end
end
