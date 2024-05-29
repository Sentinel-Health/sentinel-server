class CreateBiomarkerSubcategories < ActiveRecord::Migration[7.1]
  def change
    create_table :biomarker_subcategories, id: :uuid do |t|
      t.references :biomarker_category, null: false, foreign_key: true, type: :uuid
      t.string :name, null: false
      t.string :description

      t.timestamps
    end
  end
end
