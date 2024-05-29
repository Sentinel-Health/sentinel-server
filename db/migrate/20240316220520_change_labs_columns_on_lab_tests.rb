class ChangeLabsColumnsOnLabTests < ActiveRecord::Migration[7.1]
  def change
    add_reference :lab_tests, :lab, type: :uuid, foreign_key: true
    remove_column :lab_tests, :lab_name, :string
    remove_column :lab_tests, :vital_lab_id, :integer
  end
end
