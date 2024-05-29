class ChangeDefaultToInactiveForLabTests < ActiveRecord::Migration[7.1]
  def change
    change_column_default :lab_tests, :status, from: 'active', to: 'inactive'
  end
end
