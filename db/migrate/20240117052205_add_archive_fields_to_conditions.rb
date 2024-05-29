class AddArchiveFieldsToConditions < ActiveRecord::Migration[7.1]
  def change
    add_column :conditions, :archived_at, :datetime
    add_column :conditions, :is_archived, :boolean, default: false
  end
end
