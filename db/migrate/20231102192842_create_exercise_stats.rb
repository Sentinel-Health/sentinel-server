class CreateExerciseStats < ActiveRecord::Migration[7.1]
  def change
    create_table :exercise_stats, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.float :average_steps_per_day
      t.float :average_workouts_per_week
      t.float :average_resting_heart_rate
      t.float :latest_vo2_max

      t.timestamps
    end
  end
end
