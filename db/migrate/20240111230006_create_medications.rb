class CreateMedications < ActiveRecord::Migration[7.1]
  def change
    create_table :medications, id: :uuid do |t|
      t.references :clinical_record, type: :uuid, null: false, foreign_key: true
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.string :name
      t.string :dosage_instructions
      t.string :status
      t.datetime :authored_on
      t.string :authored_by

      t.timestamps
    end
  end
end
