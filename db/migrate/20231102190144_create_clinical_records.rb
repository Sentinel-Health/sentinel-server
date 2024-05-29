class CreateClinicalRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :clinical_records, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :type
      t.string :identifier, null: false
      t.string :source_name
      t.string :source_version
      t.string :fhir_release
      t.string :fhir_version
      t.datetime :received_date
      t.json :fhir_data

      t.timestamps
    end
  end
end
