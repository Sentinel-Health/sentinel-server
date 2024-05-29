class CreateNotificationSettings < ActiveRecord::Migration[7.1]
  def change
    create_table :notification_settings, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.boolean :push_notifications_enabled, default: false
      t.boolean :email_notifications_enabled, default: true

      t.timestamps
    end
  end
end
