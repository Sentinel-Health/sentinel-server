class CreateHealthQuantitySummaries < ActiveRecord::Migration[7.1]
  def change
    create_table :health_quantity_summaries, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.string :data_type, null: false
      t.string :summary_type, null: false
      t.string :unit
      t.float :value, null: false
      t.date :date

      t.timestamps
    end

    add_index :health_quantity_summaries, [:user_id, :data_type, :summary_type, :date], unique: true
  end
end
