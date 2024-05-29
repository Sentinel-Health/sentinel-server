class AddAdditionalDataToUserNotifications < ActiveRecord::Migration[7.1]
  def change
    add_column :user_notifications, :additional_data, :json
  end
end
