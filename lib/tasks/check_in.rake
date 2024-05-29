namespace :check_in do
  desc "Create a daily checkin conversation for all users"
  task daily: :environment do
    User.find_each do |user|
      if user.notification_setting.daily_checkin && time_to_run?(user)
        CheckInJob.perform_later(user.id)
      end
    end
  end
end

def time_to_run?(user)
  now = Time.current.in_time_zone(user.timezone)
  nearest_hour = now.beginning_of_hour
  if now.min >= 30
    nearest_hour += 1.hour
  end

  if nearest_hour.hour == user.notification_setting.daily_checkin_time.hour
    return true
  else
    return false
  end
end
