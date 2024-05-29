class AddIsOnboardingToConversations < ActiveRecord::Migration[7.1]
  def change
    add_column :conversations, :is_onboarding, :boolean, default: false
  end
end
