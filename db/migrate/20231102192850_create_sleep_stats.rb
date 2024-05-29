class CreateSleepStats < ActiveRecord::Migration[7.1]
  def change
    create_table :sleep_stats, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.float :average_hours_slept

      t.timestamps
    end
  end
end
