class AddNotificationTypeEnumToUserNotifications < ActiveRecord::Migration[7.1]
  def change
    add_column :user_notifications, :notification_type, :string, null: false, default: 'generic'
  end
end
