class RenameDescriptionToShortDescriptionForLabTests < ActiveRecord::Migration[7.1]
  def change
    rename_column :lab_tests, :description, :short_description
  end
end
