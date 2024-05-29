class AddDetailedStatusToLabTestOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :lab_test_orders, :detailed_status, :string
  end
end
