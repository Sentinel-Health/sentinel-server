class SessionAuditTrail < ApplicationRecord
  belongs_to :user, optional: true

  enum event: {
    unknown: 'unknown',
    authentication_failure: 'authentication_failure',
    login: 'login',
    login_failure: 'login_failure',
    logout: 'logout',
    logout_failure: 'logout_failure',
    session_refresh: 'session_refresh',
    session_refresh_failure: 'session_refresh_failure',
    session_fetch: 'session_fetch'
  }

  def self.log_event(event, request, browser, user, metadata = {})
    Rails.logger.info("Logging session event: #{event}")
    Thread.new do
      ActiveRecord::Base.connection_pool.with_connection do
        SessionAuditTrail.create(
          event: event.nil? ? :unknown : event,
          user_id: user.nil? ? nil : user.id,
          ip_address: request.nil? ? "N/A" : request.ip,
          user_agent: request.nil? ? "N/A" : request.user_agent,
          device: browser.nil? ? "N/A" : browser.device.name,
          platform: browser.nil? ? "N/A" : browser.platform.name,
          metadata: metadata
        )
      end
    end
  end
end
