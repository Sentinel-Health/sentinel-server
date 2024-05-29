class Device < ApplicationRecord
  belongs_to :user

  after_create :register_with_sns!
  after_destroy :deregister_from_sns

  def send_background_notification(notification)
    aps = {
      content_available: true,
    }

    message = {
      default: notification.body,
      APNS: {
        aps: aps,
        type: notification.notification_type,
        data: notification.additional_data,
        notification_id: notification.id,
      }.to_json,
      APNS_SANDBOX: {
        aps: aps,
        type: notification.notification_type,
        data: notification.additional_data,
        notification_id: notification.id,
      }.to_json,
    }

    resp = $sns.publish({
      target_arn: self.aws_platform_endpoint_arn,
      message: message.to_json,
      message_structure: 'json'
    })

    Rails.logger.info("Sent background fetch notification #{notification.id} to #{self.user.id}")

  rescue Aws::SNS::Errors::EndpointDisabled => e
    Rails.logger.error("Endpoint disabled for device: #{self.id}")
    self.destroy
  rescue Aws::SNS::Errors::EndpointNotFound => e
    Rails.logger.error("Endpoint not found for device: #{self.id}")
    self.destroy
  rescue Aws::SNS::Errors::InvalidParameter => e
    Rails.logger.error("Invalid parameter for device: #{self.id} (#{e.message})")
  rescue Aws::SNS::Errors::AuthorizationError => e
    Rails.logger.error("Authorization error for device: #{self.id} (#{e.message})")
  end

  def send_push_notification(notification)
    # badge_count = self.user.notifications.unread.count

    if notification.is_background_notification
      aps = {
        content_available: true,
      }
    else
      aps = {
        sound: 'default',
        alert: {
          title: notification.title,
          body: notification.body,
        },
        # badge: badge_count,
        category: notification.action,
      }
    end

    message = {
      default: notification.body,
      APNS: {
        aps: aps,
        type: notification.notification_type,
        data: notification.additional_data,
        notification_id: notification.id,
      }.to_json,
      APNS_SANDBOX: {
        aps: aps,
        type: notification.notification_type,
        data: notification.additional_data,
        notification_id: notification.id,
      }.to_json,
    }

    resp = $sns.publish({
      target_arn: self.aws_platform_endpoint_arn,
      message: message.to_json,
      message_structure: 'json'
    })

    Rails.logger.info("Sent push notification #{notification.id} to #{self.user.id}")

  rescue Aws::SNS::Errors::EndpointDisabled => e
    Rails.logger.error("Endpoint disabled for device: #{self.id}")
    self.destroy
  rescue Aws::SNS::Errors::EndpointNotFound => e
    Rails.logger.error("Endpoint not found for device: #{self.id}")
    self.destroy
  rescue Aws::SNS::Errors::InvalidParameter => e
    Rails.logger.error("Invalid parameter for device: #{self.id} (#{e.message})")
  rescue Aws::SNS::Errors::AuthorizationError => e
    Rails.logger.error("Authorization error for device: #{self.id} (#{e.message})")
  end

  private 

  def register_with_sns!
    if self.device_type == 'ios'
      platform_application_arn = ENV['AWS_SNS_IOS_PLATFORM_APPLICATION_ARN']
    else
      raise 'Unsupported device type'
    end
    resp = $sns.create_platform_endpoint({
      platform_application_arn: platform_application_arn,
      token: self.token,
      attributes: {
        'UserId' => self.user.id,
      }
    })
    self.aws_platform_endpoint_arn = resp[:endpoint_arn]
    self.save!
  end

  def deregister_from_sns
    $sns.delete_endpoint({
      endpoint_arn: self.aws_platform_endpoint_arn,
    })
  end
end
