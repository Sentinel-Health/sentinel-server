class Admin::UserJson
  def initialize(user)
    @user = user
  end

  def call(options=nil)
    return to_json(@user, options) unless @user.respond_to?(:each)
    @user.map { |user| to_json(user, options) }
  end

  private

  def to_json(user, options)
    return nil unless user
    Rails.cache.fetch("json/admin/v1.0/#{user.cache_key_with_version}") do
      {
        id: user.id,
        email: user.email,
        full_name: user.full_name,
        phone_number: user.phone_number,
        phone_number_verified: user.phone_number_verified,
        picture: user.picture,
        first_name: user.first_name,
        last_name: user.last_name,
        address_line_1: user.address_line_1,
        address_line_2: user.address_line_2,
        city: user.city,
        state: user.state,
        zip_code: user.zip_code,
        country: user.country,
        address_string: user.address_string,
        has_completed_onboarding: user.has_completed_onboarding,
        is_syncing_health_data: user.is_syncing_health_data,
        data_sync_completed_at: user.data_sync_completed_at,
        number_of_lab_test_orders: user.number_of_lab_test_orders,
        notificationSettings: {
          push_notifications_enabled: user.notification_setting.push_notifications_enabled,
          email_notifications_enabled: user.notification_setting.email_notifications_enabled,
          daily_checkin: user.notification_setting.daily_checkin,
          daily_checkin_time: user.notification_setting.daily_checkin_time,
        }
      }
    end
  end
end