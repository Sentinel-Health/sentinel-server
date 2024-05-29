class CreateWorkouts < ActiveRecord::Migration[7.1]
  def change
    create_table :workouts, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :identifier, null: false
      t.string :activity_type
      t.float :duration
      t.string :duration_unit
      t.float :total_distance
      t.string :total_distance_unit
      t.float :total_energy_burned
      t.string :total_energy_burned_unit
      t.string :source_name
      t.string :source_version
      t.string :device
      t.datetime :start_date
      t.datetime :end_date
      t.json :metadata

      t.timestamps
    end
  end
end
