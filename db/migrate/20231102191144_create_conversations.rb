class CreateConversations < ActiveRecord::Migration[7.1]
  def change
    create_table :conversations, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.datetime :last_activity_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
      t.string :title
      t.string :summary

      t.timestamps
    end
  end
end
