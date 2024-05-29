class CreateChatFeedbacks < ActiveRecord::Migration[7.1]
  def change
    create_table :chat_feedbacks, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :message, null: false, foreign_key: true, type: :uuid
      t.string :feedback_type, null: false

      t.timestamps
    end
  end
end
