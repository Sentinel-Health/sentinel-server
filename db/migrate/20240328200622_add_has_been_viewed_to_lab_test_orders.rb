class AddHasBeenViewedToLabTestOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :lab_test_orders, :results_have_been_viewed, :boolean, default: false
  end
end
