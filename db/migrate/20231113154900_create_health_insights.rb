class CreateHealthInsights < ActiveRecord::Migration[7.1]
  def change
    create_table :health_insights, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :category, null: false, default: 'unknown'
      t.string :model_used
      t.json :insights

      t.timestamps
    end
  end
end
