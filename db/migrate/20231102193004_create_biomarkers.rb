class CreateBiomarkers < ActiveRecord::Migration[7.1]
  def change
    create_table :biomarkers, id: :uuid do |t|
      t.references :biomarker_subcategory, null: false, foreign_key: true, type: :uuid
      t.string :name, null: false
      t.string :description
      t.string :unit
      t.json :reference_range
      t.string :alternative_names, array: true, default: [], null: false

      t.timestamps
    end
  end
end
