class UserNotificationJson
  def initialize(notification)
    @notification = notification
  end

  def call(options=nil)
    return to_json(@notification, options) unless @notification.respond_to?(:each)
    @notification.map { |notification| to_json(notification, options) }
  end

  private

  def to_json(notification, options)
    return nil unless notification
    Rails.cache.fetch("json/v1.0/#{notification.cache_key_with_version}") do
      {
        id: notification.id,
        title: notification.title,
        body: notification.body,
        action: notification.action,
        notificationType: notification.notification_type,
        additionalData: notification.additional_data,
        read: notification.read,
        createdAt: notification.created_at,
      }
    end
  end
end