class CreateBiomarkerCategories < ActiveRecord::Migration[7.1]
  def change
    create_table :biomarker_categories, id: :uuid do |t|
      t.string :name, null: false
      t.string :description

      t.timestamps
    end
  end
end
