class UpdateLabResultsForLabOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :lab_results, :value_quantity, :float
    add_column :lab_results, :unit, :string
    add_column :lab_results, :reference_range_json, :jsonb, default: {}
    add_reference :lab_results, :lab_test_order, type: :uuid, foreign_key: true
  end
end
