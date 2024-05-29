class AddOrderNumberToLabTestOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :lab_test_orders, :order_number, :bigint
    add_index :lab_test_orders, :order_number, unique: true
  end
end
