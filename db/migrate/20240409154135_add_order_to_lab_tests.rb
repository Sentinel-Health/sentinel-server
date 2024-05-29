class AddOrderToLabTests < ActiveRecord::Migration[7.1]
  def change
    add_column :lab_tests, :order, :integer, default: 0
  end
end
