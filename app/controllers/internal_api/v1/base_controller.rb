class InternalApi::V1::BaseController < InternalApi::BaseController
  before_action :authenticate_user!
  after_action :update_session_latest_info

  private

  def authenticate_user!
    auth_header = request.headers['Authorization']
    raise InternalApi::Unauthorized.new(I18n.t("auth.errors.unauthorized")) unless auth_header
    
    access_token = auth_header.split('Bearer ').last
    @current_session = Session.find_and_verify(access_token)
    raise InternalApi::Unauthorized.new(I18n.t("auth.errors.unauthorized")) unless @current_session
    
    @current_user = @current_session.user
  rescue => e
    SessionAuditTrail.log_event(:authentication_failure, request, browser, nil, {
      error: "Authentication failed - #{e.message}",
      auth_header: auth_header
    })
    raise e
  end

  def update_session_latest_info
    @current_session.update(
      ip_address: request.remote_ip,
      device: browser.device.name,
      platform: browser.platform.name
    )
  end
end
