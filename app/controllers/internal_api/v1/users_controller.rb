require 'openssl'

class InternalApi::V1::UsersController < InternalApi::V1::BaseController
  def show
    render json: UserJson.new(@current_user).call
  end

  def update
    user_params = params.require(:user).permit(permitted_user_params)
    @current_user.update!(user_params)
    @current_user.reload
    render json: UserJson.new(@current_user).call
  end

  def send_phone_verification_code
    phone_number = params[:phone_number]
    raise InternalApi::BadRequest.new(I18n.t("users.errors.invalid_phone_number")) unless Phonelib.valid?(phone_number)
    phone = Phonelib.parse(phone_number).to_s
    verification = $twilio.verify.v2.services(Rails.application.credentials.dig(:twilio, :verify_sid)).verifications.create(
      to: phone, 
      channel: 'sms'
    )
    @current_user.update!(phone_number: phone, phone_number_verified: false)
  end

  def verify_phone_number
    code = params[:verification_code]
    verification_check = $twilio.verify.v2.services(Rails.application.credentials.dig(:twilio, :verify_sid)).verification_checks.create(
      to: @current_user.phone_number, 
      code: code
    )
    if verification_check.status == 'approved'
      @current_user.update!(phone_number_verified: true)
      render json: UserJson.new(@current_user).call
    else
      raise InternalApi::BadRequest.new(I18n.t("users.errors.invalid_verification_code"))
    end
  end

  def show_notifications
    @notifications = @current_user.notifications.user_readable
    @notifications = @notifications.unread if params[:unread] == 'true'
    @notifications = @notifications.order(created_at: :desc)
    render json: {
      notifications: @notifications.map { |n| UserNotificationJson.new(n).call }
    }
  end

  def get_unread_notification_count
    render json: { count: @current_user.notifications.user_readable.unread.count }
  end

  def update_notification_settings
    settings = params.require(:notification_settings).permit(
      :push_notifications_enabled, 
      :email_notifications_enabled,
      :daily_checkin,
      :daily_checkin_time
    )
    @current_user.notification_setting.update!(settings)
    render json: UserJson.new(@current_user).call
  end

  def mark_notification_as_read
    notification_id = params[:notification_id]
    notification = UserNotification.find(notification_id)
    notification.mark_as_read!
    render json: { success: true }
  end

  def start_data_sync
    unless @current_user.is_syncing_health_data == true
      @current_user.update!(is_syncing_health_data: true, data_sync_started_at: Time.now)
    end
    render json: { success: true }
  end

  def complete_data_sync
    if @current_user.is_syncing_health_data == true
      @current_user.update!(is_syncing_health_data: false, data_sync_completed_at: Time.now)
      notification = UserNotification.create(
        user_id: @current_user.id,
        title: 'Data Sync Complete',
        body: 'Your data has finished syncing! All of your data is now available in the app.',
        notification_type: :completed_data_sync,
        additional_data: {
          data_sync_started_at: @current_user.data_sync_started_at,
          data_sync_completed_at: @current_user.data_sync_completed_at
        }
      )
      SendUserNotificationsJob.perform_later(@current_user.id, notification.id) unless !@current_user.has_completed_onboarding
      GenerateChatSuggestionsJob.perform_later(@current_user.id)
    end
    render json: { success: true }
  end

  private

  def permitted_user_params
    [
      :first_name,
      :last_name,
      :address_line_1,
      :address_line_2,
      :city,
      :state,
      :zip_code,
      :country,
      :timezone
    ]
  end
end