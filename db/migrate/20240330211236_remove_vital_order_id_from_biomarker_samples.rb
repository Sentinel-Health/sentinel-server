class RemoveVitalOrderIdFromBiomarkerSamples < ActiveRecord::Migration[7.1]
  def change
    remove_column :biomarker_samples, :vital_order_id, :string
  end
end
