class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages, id: :uuid do |t|
      t.references :conversation, null: false, foreign_key: true, type: :uuid
      t.string :name
      t.string :role, null: false
      t.string :content
      t.json :function_call

      t.timestamps
    end
  end
end
