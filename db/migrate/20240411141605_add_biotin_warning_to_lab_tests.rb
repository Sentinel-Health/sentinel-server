class AddBiotinWarningToLabTests < ActiveRecord::Migration[7.1]
  def change
    add_column :lab_tests, :has_biotin_interference_potential, :boolean, default: false, null: false
  end
end
