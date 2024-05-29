class GenerateChatSuggestionsJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    user.generate_chat_suggestions(10)
  end
end
