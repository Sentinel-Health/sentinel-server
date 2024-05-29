class CreateUserNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :user_notifications, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :title
      t.string :body
      t.string :action
      t.string :action_data
      t.boolean :read, default: false

      t.timestamps
    end
  end
end
