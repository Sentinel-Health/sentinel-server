class UserJson
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
    Rails.cache.fetch("json/v1.4/#{user.cache_key_with_version}") do
      {
        id: user.id,
        email: user.email,
        fullName: user.full_name,
        phoneNumber: user.phone_number,
        phoneNumberVerified: user.phone_number_verified,
        picture: user.picture,
        firstName: user.first_name,
        lastName: user.last_name,
        addressLine1: user.address_line_1,
        addressLine2: user.address_line_2,
        city: user.city,
        state: user.state,
        zipCode: user.zip_code,
        country: user.country,
        addressString: user.address_string,
        hasCompletedOnboarding: user.has_completed_onboarding,
        isSyncingHealthData: user.is_syncing_health_data,
        dataSyncCompletedAt: user.data_sync_completed_at,
        labTestOrdersCount: user.number_of_lab_test_orders,
        notificationSettings: {
          enabledPushNotifications: user.notification_setting.push_notifications_enabled,
          enabledEmailNotifications: user.notification_setting.email_notifications_enabled,
          dailyCheckin: user.notification_setting.daily_checkin,
          dailyCheckinTime: user.notification_setting.daily_checkin_time,
        }
      }
    end
  end
end