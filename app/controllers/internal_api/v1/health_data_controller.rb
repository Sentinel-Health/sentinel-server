class InternalApi::V1::HealthDataController < InternalApi::V1::BaseController
  def fitness_stats
    latest_steps = @current_user.health_quantity_summaries.where(data_type: "Step Count").order(date: :desc).limit(1).first
    if latest_steps.present?
      steps = {
        latestMeasurement: {
          value: latest_steps.value,
          description: "latest measurement",
          from: latest_steps.date.in_time_zone(@current_user.timezone).to_datetime
        }
      }

      avg_steps_per_day_last_month = @current_user.average_daily_steps(1.month.ago, Time.now)
      if avg_steps_per_day_last_month.present?
        steps[:trendMeasurement] = {
          value: avg_steps_per_day_last_month,
          description: "avg per day in past month",
        }
      end
    else
      steps = nil
    end

    latest_resting_heart_rate = @current_user.get_most_recent_quantity_sample("Resting Heart Rate")
    if latest_resting_heart_rate.present?
      resting_heart_rate = {
        latestMeasurement: {
          value: latest_resting_heart_rate.value,
          description: "latest measurement",
          unit: "bpm",
          from: latest_resting_heart_rate.start_date
        }
      }

      avg_resting_heart_rate_last_month = @current_user.average_resting_heart_rate
      if avg_resting_heart_rate_last_month.present?
        resting_heart_rate[:trendMeasurement] = {
          value: avg_resting_heart_rate_last_month.dig(:value),
          description: "avg past month",
          unit: "bpm",
        }
      end
    else 
      resting_heart_rate = nil
    end

    latest_vo2_max = @current_user.get_most_recent_quantity_sample("VO2 Max")
    if latest_vo2_max.present?
      vo2_max = {
        latestMeasurement: {
          value: latest_vo2_max.value,
          unit: latest_vo2_max.unit,
          description: "latest measurement",
          from: latest_vo2_max.start_date
        }
      }

      avg_vo2_max_last_month = @current_user.average_vo2_max
      if avg_vo2_max_last_month.present?
        vo2_max[:trendMeasurement] = {
          value: avg_vo2_max_last_month.dig(:value),
          description: "avg past month",
          unit: avg_vo2_max_last_month.dig(:unit),
        }
      end
    else
      vo2_max = nil
    end

    latest_respiratory_rate = @current_user.get_most_recent_quantity_sample("Respiratory Rate")
    if latest_respiratory_rate.present?
      respiratory_rate = {
        latestMeasurement: {
          value: latest_respiratory_rate.value,
          description: "latest measurement",
          unit: "brpm",
          from: latest_respiratory_rate.start_date
        }
      }

      avg_respiratory_rate_last_month = @current_user.average_respiratory_rate
      if avg_respiratory_rate_last_month.present?
        respiratory_rate[:trendMeasurement] = {
          value: avg_respiratory_rate_last_month.dig(:value),
          description: "avg past month",
          unit: "brpm",
        }
      end
    else
      respiratory_rate = nil
    end

    current_week_workouts = @current_user.get_cleaned_workouts_over_range(start_date: Time.now.beginning_of_week, end_date: Time.now.end_of_week)
    if @current_user.workouts.any?
      workouts = {
        latestMeasurement: {
          from: current_week_workouts.first ? current_week_workouts.first.end_date : Time.now,
          value: current_week_workouts.sum(&:duration) / 60.0,
          description: "this week",
          unit: "mins this week"
        }
      }

      average_duration = @current_user.average_weekly_workout_mins(1.month.ago, 1.week.ago)
      if average_duration.present?
        workouts[:trendMeasurement] = {
          value: average_duration,
          description: "avg per week in past month",
          unit: "mins"
        }
      end
    else
      workouts = nil
    end

    render json: {
      steps: steps,
      workouts: workouts,
      restingHeartRate: resting_heart_rate,
      vo2Max: vo2_max,
      respiratoryRate: respiratory_rate,
    }
  end

  def sleep_stats
    latest_sleep = @current_user.get_most_recent_sleep
    if latest_sleep.present?
      sleep = {
        latestMeasurement: {
          value: latest_sleep.dig(:value),
          description: "latest measurement",
          from: latest_sleep.dig(:date)
        }
      }

      average_sleep = @current_user.average_hours_slept
      if average_sleep.present?
        sleep[:trendMeasurement] = {
          value: average_sleep,
          description: "avg per night in past month",
        }
      end
    else
      sleep = nil
    end

    render json: {
      sleep: sleep
    }
  end

  def body_stats
    height_sample = @current_user.get_most_recent_quantity_sample("Height")
    if height_sample.present?
      height = {
        latestMeasurement: {
          value: height_sample.value,
          description: "latest measurement",
          unit: height_sample.unit,
          from: height_sample.start_date
        }
      }
    else
      height = nil
    end

    latest_weight = @current_user.get_most_recent_quantity_sample("Body Mass")
    if latest_weight.present?
      weight = {
        latestMeasurement: {
          value: latest_weight.value,
          description: "latest measurement",
          unit: latest_weight.unit,
          from: latest_weight.start_date
        }
      }

      avg_weight_last_month = @current_user.average_weight
      if avg_weight_last_month.present?
        weight[:trendMeasurement] = {
          value: avg_weight_last_month.dig(:value),
          description: "avg past month",
          unit: avg_weight_last_month.dig(:unit),
        }
      end
    else
      weight = nil
    end

    latest_body_fat = @current_user.get_most_recent_quantity_sample("Body Fat Percentage")
    if latest_body_fat.present?
      body_fat = {
        latestMeasurement: {
          value: latest_body_fat.value * 100,
          description: "latest measurement",
          unit: "%",
          from: latest_body_fat.start_date
        }
      }

      avg_body_fat_last_month = @current_user.average_body_fat
      if avg_body_fat_last_month.present?
        body_fat[:trendMeasurement] = {
          value: avg_body_fat_last_month.dig(:value) * 100,
          description: "avg past month",
          unit: "%",
        }
      end
    else 
      body_fat = nil
    end

    latest_bmi = @current_user.get_most_recent_quantity_sample("Body Mass Index")
    if latest_bmi.present?
      bmi = {
        latestMeasurement: {
          value: latest_bmi.value,
          description: "latest measurement",
          unit: nil,
          from: latest_bmi.start_date
        }
      }

      avg_bmi_last_month = @current_user.average_bmi
      if avg_bmi_last_month.present?
        bmi[:trendMeasurement] = {
          value: avg_bmi_last_month.dig(:value),
          description: "avg past month",
          unit: nil,
        }
      end
    else 
      bmi = nil
    end

    render json: {
      height: height,
      weight: weight,
      bodyFat: body_fat,
      bmi: bmi
    }
  end
end