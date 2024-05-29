class AddStatusToLabTestOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :lab_test_orders, :status, :string, null: false, default: 'received'
  end
end
