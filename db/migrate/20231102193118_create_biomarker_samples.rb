class CreateBiomarkerSamples < ActiveRecord::Migration[7.1]
  def change
    create_table :biomarker_samples, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :biomarker, foreign_key: true, type: :uuid
      t.references :clinical_record, null: false, foreign_key: true, type: :uuid
      t.string :name
      t.datetime :issued
      t.float :value
      t.string :value_unit
      t.string :value_string
      t.string :reference_range_string
      t.json :reference_range

      t.timestamps
    end
  end
end
