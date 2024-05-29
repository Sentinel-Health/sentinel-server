class AddArchiveFieldsToMedications < ActiveRecord::Migration[7.1]
  def change
    add_column :medications, :archived_at, :datetime
    add_column :medications, :is_archived, :boolean, default: false
  end
end
