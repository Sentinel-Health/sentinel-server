class ChangeDailyCheckinNotificationSettingDefault < ActiveRecord::Migration[7.1]
  def change
    change_column_default :notification_settings, :daily_checkin, from: true, to: false
  end
end
