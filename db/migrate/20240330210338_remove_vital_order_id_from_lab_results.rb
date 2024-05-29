class RemoveVitalOrderIdFromLabResults < ActiveRecord::Migration[7.1]
  def change
    remove_column :lab_results, :vital_order_id, :string
  end
end
