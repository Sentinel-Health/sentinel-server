class CreateLabResults < ActiveRecord::Migration[7.1]
  def change
    create_table :lab_results, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :clinical_record, null: false, foreign_key: true, type: :uuid
      t.string :name
      t.datetime :issued
      t.string :value
      t.string :reference_range

      t.timestamps
    end
  end
end
