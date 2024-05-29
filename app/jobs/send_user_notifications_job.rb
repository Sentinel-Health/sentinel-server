class SendUserNotificationsJob < ApplicationJob
  queue_as :default

  def perform(user_id, notification_id)
    Rails.logger.info("Sending notification #{notification_id} to #{user_id}")
    user = User.find(user_id)
    notification = UserNotification.find(notification_id)
    user.send_notification(notification)
  end
end
