class CreateHealthSummaries < ActiveRecord::Migration[7.1]
  def change
    create_table :health_summaries, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :category, null: false, default: 'unknown'
      t.string :summary, null: false
      t.string :model_used

      t.timestamps
    end
  end
end
