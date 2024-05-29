class UpdateUserNotificationsActionDataToJson < ActiveRecord::Migration[7.1]
  def change
    change_column :user_notifications, :action_data, :json, using: 'action_data::json'
  end
end
