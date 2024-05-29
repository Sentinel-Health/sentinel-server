class AddReferenceRangeStringToBiomarkers < ActiveRecord::Migration[7.1]
  def change
    add_column :biomarkers, :reference_range_string, :string
  end
end
