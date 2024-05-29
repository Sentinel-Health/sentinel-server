class Conversation < ApplicationRecord
  belongs_to :user

  has_many :messages, dependent: :destroy

  def self.with_user_message
    joins(:messages).where(messages: { role: 'user' }).distinct
  end

  include SummaryService
  def create_title
    messages = self.messages.where(role: ['user', 'assistant']).order(created_at: :asc)
    prompt = messages.map { |message| "#{message.role}:\n#{message.content}" }.join("\n\n")
    title = get_conversation_title(prompt)
    self.title = title
    self.save
  end
end
