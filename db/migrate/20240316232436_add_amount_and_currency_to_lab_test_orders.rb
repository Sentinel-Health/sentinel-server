class AddAmountAndCurrencyToLabTestOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :lab_test_orders, :amount, :decimal, precision: 19, scale: 4, null: false, default: 0.0
    add_column :lab_test_orders, :currency, :string, default: "USD", null: false
  end
end
