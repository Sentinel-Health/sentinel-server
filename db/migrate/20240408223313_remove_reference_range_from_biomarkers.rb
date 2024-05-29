class RemoveReferenceRangeFromBiomarkers < ActiveRecord::Migration[7.1]
  def change
    remove_column :biomarkers, :reference_range, :json
    remove_column :biomarkers, :reference_range_string, :string
  end
end
