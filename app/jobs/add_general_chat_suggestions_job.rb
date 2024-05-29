require 'csv'

class AddGeneralChatSuggestionsJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    Rails.logger.info("creating suggestions for: #{user_id}")
    chat_suggestions = CSV.read("lib/data/general_chat_suggestions.csv", headers: true)
    chat_suggestions.each do |suggestion|
      ChatSuggestion.create(
        user_id: user_id,
        title: suggestion["title"],
        description: suggestion["description"],
        prompt: suggestion["prompt"],
      )
    end
    Rails.logger.info("done.")
  end
end
