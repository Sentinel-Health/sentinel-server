class AddResultsFieldsToLabTestOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :lab_test_orders, :results_status, :string, default: 'final'
    add_column :lab_test_orders, :results_reported_at, :datetime
    add_column :lab_test_orders, :results_collected_at, :datetime
  end
end
