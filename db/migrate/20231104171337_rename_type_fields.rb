class RenameTypeFields < ActiveRecord::Migration[7.1]
  def change
    rename_column :clinical_records, :type, :record_type
    rename_column :health_quantity_samples, :type, :sample_type
    rename_column :health_category_samples, :type, :sample_type
  end
end
