class CreateVitalLabTestResults < ActiveRecord::Migration[7.1]
  def change
    create_table :vital_lab_test_results, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.string :vital_order_id, null: false
      t.text :results_data
      t.datetime :date_reported, null: false
      t.datetime :date_received
      t.datetime :date_collected
      t.string :specimen_number, null: false
      t.string :status
      t.string :interpretation

      t.timestamps
    end
  end
end
