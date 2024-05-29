class CreateConditions < ActiveRecord::Migration[7.1]
  def change
    create_table :conditions, id: :uuid do |t|
      t.references :clinical_record, type: :uuid, null: false, foreign_key: true
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.string :name
      t.string :status
      t.datetime :recorded_on
      t.string :recorded_by

      t.timestamps
    end
  end
end
