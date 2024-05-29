class CreateHealthQuantitySamples < ActiveRecord::Migration[7.1]
  def change
    create_table :health_quantity_samples, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :type, null: false
      t.string :unit
      t.float :value, null: false
      t.string :identifier, null: false
      t.string :source_name
      t.string :source_version
      t.string :device
      t.datetime :start_date
      t.datetime :end_date
      t.json :metadata

      t.timestamps
    end
  end
end
