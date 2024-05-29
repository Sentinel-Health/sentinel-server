class NewLabResultsNotificationJob < ApplicationJob
  queue_as :default

  def perform(user_id, new_lab_results_ids)
    user = User.find(user_id)
    # Don't send notifications if the user is currently performing initial sync
    unless user.is_syncing_health_data
      user.send_new_lab_results_notification(new_lab_results_ids)
    end
  end
end
