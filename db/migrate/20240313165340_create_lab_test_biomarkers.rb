class CreateLabTestBiomarkers < ActiveRecord::Migration[7.1]
  def change
    create_table :lab_test_biomarkers, id: :uuid do |t|
      t.references :lab_test, null: false, foreign_key: true, type: :uuid
      t.references :biomarker, null: false, foreign_key: true, type: :uuid
      t.json :loinic_info

      t.timestamps
    end
  end
end
