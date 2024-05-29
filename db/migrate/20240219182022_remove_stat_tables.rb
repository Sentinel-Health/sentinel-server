class RemoveStatTables < ActiveRecord::Migration[7.1]
  def change
    drop_table :exercise_stats
    drop_table :sleep_stats
  end
end
