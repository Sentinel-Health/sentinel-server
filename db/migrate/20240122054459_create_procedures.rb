class CreateProcedures < ActiveRecord::Migration[7.1]
  def change
    create_table :procedures, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :clinical_record, null: false, foreign_key: true, type: :uuid
      t.string :name
      t.string :status
      t.date :performed_on
      t.boolean :is_archived, default: false
      t.datetime :archived_at

      t.timestamps
    end
  end
end
