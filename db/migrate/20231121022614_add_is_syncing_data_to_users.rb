class AddIsSyncingDataToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :is_syncing_health_data, :boolean, default: false
  end
end
