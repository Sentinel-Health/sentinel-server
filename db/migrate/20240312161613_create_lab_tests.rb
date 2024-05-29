class CreateLabTests < ActiveRecord::Migration[7.1]
  def change
    create_table :lab_tests, id: :uuid do |t|
      t.string :name, null: false
      t.string :description, null: false
      t.string :status, null: false, default: 'active'
      t.string :category, null: false, default: 'standard'
      t.string :collection_method, null: false, default: 'walk_in_test'
      t.string :sample_type, null: false, default: 'serum'
      t.boolean :is_fasting_required, null: false, default: true
      t.integer :vital_lab_id
      t.decimal :price, precision: 19, scale: 4, null: false
      t.string :currency, default: "USD", null: false

      t.timestamps
    end
  end
end
