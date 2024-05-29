class AddDataSyncTimestampsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :data_sync_started_at, :datetime
    add_column :users, :data_sync_completed_at, :datetime
  end
end
