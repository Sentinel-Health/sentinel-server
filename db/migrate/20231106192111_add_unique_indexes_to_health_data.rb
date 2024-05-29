class AddUniqueIndexesToHealthData < ActiveRecord::Migration[7.1]
  def change
    add_index :health_quantity_samples, [:user_id, :identifier], unique: true
    add_index :health_category_samples, [:user_id, :identifier], unique: true
    add_index :workouts, [:user_id, :identifier], unique: true
  end
end
