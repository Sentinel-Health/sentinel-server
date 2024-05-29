class AddVitalOrderIdToBiomarkerSamplesAndLabResults < ActiveRecord::Migration[7.1]
  def change
    add_column :biomarker_samples, :vital_order_id, :string
    add_column :lab_results, :vital_order_id, :string
  end
end
