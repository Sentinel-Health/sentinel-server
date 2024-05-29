class AddIsBackgroundNotificationToUserNotifications < ActiveRecord::Migration[7.1]
  def change
    add_column :user_notifications, :is_background_notification, :boolean, default: false
  end
end
