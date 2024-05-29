class Workout < ApplicationRecord
  belongs_to :user

  scope :over_range, ->(start_date, end_date) { where('start_date >= ? AND end_date <= ?', start_date.beginning_of_day, end_date.end_of_day) }

  def self.remove_overlaps(workouts)
    non_overlapping_workouts = []

    workouts.order(end_date: :desc).each do |workout|
      if non_overlapping_workouts.empty? || workout.end_date <= non_overlapping_workouts.last.start_date
        non_overlapping_workouts << workout
      end
    end

    non_overlapping_workouts
  end
end
