class UpdateNotificationSettingsForCheckins < ActiveRecord::Migration[7.1]
  def change
    add_column :notification_settings, :daily_checkin, :boolean, default: true
    add_column :notification_settings, :daily_checkin_time, :time, default: '21:00'
  end
end
