class AddHealthGoalsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :health_goals, :jsonb, default: {}
  end
end
