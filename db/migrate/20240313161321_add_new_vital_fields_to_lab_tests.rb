class AddNewVitalFieldsToLabTests < ActiveRecord::Migration[7.1]
  def change
    add_column :lab_tests, :vital_lab_test_id, :string
    add_column :lab_tests, :lab_name, :string
    add_column :lab_tests, :stripe_product_id, :string
  end
end
