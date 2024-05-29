namespace :chat_suggestions do
  desc "Create some chat suggestions for all users"
  task add_suggestions: :environment do
    Rails.logger.info "Processing chat suggestions..."
    User.all.pluck(:id).each do |user_id|
      Rails.logger.info "Scheduling chat suggestions for #{user_id}..."
      GenerateChatSuggestionsJob.perform_later(user_id)
      Rails.logger.info "Finished scheduling chat suggestions for #{user_id}"
    end
    Rails.logger.info "Finished processing chat suggestions"
  end

  desc "Import and add general chat suggestions for all users"
  task add_general_chat_suggestions: :environment do
    Rails.logger.info "Scheduling new chat suggestions..."
    User.all.pluck(:id).each do |user_id|
      AddGeneralChatSuggestionsJob.perform_later(user_id)
    end
    Rails.logger.info "finished."
  end
end
