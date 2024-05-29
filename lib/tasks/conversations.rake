namespace :conversations do
  desc "Creates titles for existing conversations with user messages"
  task create_titles: :environment do
    Rails.logger.info "Creating titles for existing conversations..."
    Conversation.with_user_message.find_each(&:create_title)
    Rails.logger.info "Done."
  end
end
