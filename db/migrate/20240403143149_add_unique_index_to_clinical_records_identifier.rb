class AddUniqueIndexToClinicalRecordsIdentifier < ActiveRecord::Migration[7.1]
  def change
    add_index :clinical_records, :identifier, unique: true
  end
end
