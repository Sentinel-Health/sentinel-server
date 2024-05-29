class CreateChatSuggestions < ActiveRecord::Migration[7.1]
  def change
    create_table :chat_suggestions, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.string :model_used
      t.boolean :was_used, default: false
      t.string :title
      t.string :description
      t.string :prompt

      t.timestamps
    end
  end
end
