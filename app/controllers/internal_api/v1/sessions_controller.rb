class InternalApi::V1::SessionsController < InternalApi::V1::BaseController
  include AppleSignInService

  skip_before_action :authenticate_user!, only: [:oauth_login, :refresh]
  skip_after_action :update_session_latest_info, only: [:oauth_login, :logout]

  def oauth_login
    provider = params[:provider]
    platform = params[:platform]
    auth_data = params[:auth_data]
    profile_data = params[:profile_data]
    case provider
    when 'apple'
      if auth_data.present?
        id_token = auth_data.dig("id_token")
        user_id = auth_data.dig("providerAccountId")
        name = profile_data.dig("name")
      else 
        # Backwards compatibility
        id_token = params[:identity_token]
        user_id = params[:user_identifier]
        name = params[:name]
      end
      return apple_login(id_token, user_id, name)
    else
      raise InternalApi::Unauthorized.new(I18n.t("auth.errors.unauthorized"))
    end
  rescue => e
    SessionAuditTrail.log_event(:login_failure, request, browser, nil, {
      error: "OAuth login failed - #{e.message}",
      provider: params[:provider]
    })
    raise e
  end

  def show
    SessionAuditTrail.log_event(:session_fetch, request, browser, @current_user)
    render json: SessionJson.new(@current_session).call
  end

  def refresh
    session = Session.find_and_verify_refresh_token(params[:refresh_token])
    unless session
      raise InternalApi::Unauthorized.new(I18n.t("auth.errors.unauthorized"))
    end
    session.refresh_access_token!
    @current_session = session
    SessionAuditTrail.log_event(:session_refresh, request, browser, @current_session.user)
    render json: SessionJson.new(@current_session, :full).call
  rescue => e
    SessionAuditTrail.log_event(:session_refresh_failure, request, browser, nil, {
      error: "Session refresh failed - #{e.message}",
      refresh_token: params[:refresh_token]
    })
    raise e
  end

  def logout
    user = @current_user
    @current_user = nil
    @current_session.destroy!
    SessionAuditTrail.log_event(:logout, request, browser, user)
    render json: {success: true}
  rescue => e
    SessionAuditTrail.log_event(:logout_failure, request, browser, nil, {
      error: "Logout failed - #{e.message}"
    })
    raise e
  end

  private

  def apple_login(id_token, user_identifier, name)
    payload = decode_and_verify_apple_id_token(id_token, user_identifier)
        
    if payload
      user = User.find_or_create_by!(email: payload['email']) do |user|
        user.first_name = name.split(' ')[0] unless name.blank?
        user.last_name = name.split(' ')[1] unless name.blank?
      end

      session = user.create_new_session(request, browser)
      SessionAuditTrail.log_event(:login, request, browser, user, {
        provider: params[:provider],
      })

      render json: SessionJson.new(session, :full).call
    else
      raise InternalApi::Unauthorized.new(I18n.t("auth.errors.unauthorized"))
    end
  end
end
