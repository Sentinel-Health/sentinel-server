class CheckInJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    if user.notification_setting.daily_checkin
      user.generate_daily_checkin
    end
  end
end
