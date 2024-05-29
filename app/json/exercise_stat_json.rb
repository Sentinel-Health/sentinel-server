class ExerciseStatJson
  def initialize(exercise_stat)
    @exercise_stat = exercise_stat
  end

  def call(options=nil)
    return to_json(@exercise_stat, options) unless @exercise_stat.respond_to?(:each)
    @exercise_stat.map { |exercise_stat| to_json(exercise_stat, options) }
  end

  private

  def to_json(exercise_stat, options)
    return nil unless exercise_stat
    Rails.cache.fetch("json/v1.0/#{exercise_stat.cache_key_with_version}") do
      {
        id: exercise_stat.id,
        averageStepsPerDay: exercise_stat.average_steps_per_day,
        averageWorkoutsPerWeek: exercise_stat.average_workouts_per_week,
        averageRestingHeartRate: exercise_stat.average_resting_heart_rate,
        latestVO2Max: exercise_stat.latest_vo2_max,
        createdAt: exercise_stat.created_at,
        updatedAt: exercise_stat.updated_at
      }
    end
  end
end