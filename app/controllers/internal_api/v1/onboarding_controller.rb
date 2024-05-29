class InternalApi::V1::OnboardingController < InternalApi::V1::BaseController
  include ChatService

  def completed_onboarding
    @current_user.update!(has_completed_onboarding: true)
    AddGeneralChatSuggestionsJob.perform_later(@current_user.id)
    render json: { success: true }
  end

  def create_conversation
    @conversation = @current_user.generate_onboarding_conversation
    render json: ConversationJson.new(@conversation).call
  end

  def get_onboarding_conversation
    @conversation = @current_user.conversations.where(is_onboarding: true).order(created_at: :desc).first
    if @conversation.empty? || @conversation.messages.empty?
      @conversation = @current_user.generate_onboarding_conversation
    end
    render json: ConversationJson.new(@conversation).call
  end

  def reset_onboarding
    @current_user.update!(has_completed_onboarding: false)
    render json: { success: true }
  end

  def confirm_consent
    accepted_policy_and_terms = params[:accepted_policy_and_terms]
    accepted_hipaa_authorization = params[:accepted_hipaa_authorization]

    if !accepted_policy_and_terms
      raise InternalApi::BadRequest.new(I18n.t("onboarding.errors.missing_policy_and_terms"))
    end

    if !accepted_hipaa_authorization
      raise InternalApi::BadRequest.new(I18n.t("onboarding.errors.missing_hipaa_consent"))
    end

    if accepted_policy_and_terms
      @current_user.user_consents.create!(
        consent_type: :privacy_policy, 
        consented_at: Time.zone.now,
        ip_address: request.remote_ip,
        user_agent: request.user_agent
      )
      @current_user.user_consents.create!(
        consent_type: :terms_of_service, 
        consented_at: Time.zone.now,
        ip_address: request.remote_ip,
        user_agent: request.user_agent
      )
      # This consent is part of the accepted_policy_and_terms
      @current_user.user_consents.create!(
        consent_type: :telehealth_consent,
        consented_at: Time.zone.now,
        ip_address: request.remote_ip,
        user_agent: request.user_agent
      )
    end
    if accepted_hipaa_authorization
      @current_user.user_consents.create!(
        consent_type: :hipaa_authorization, 
        consented_at: Time.zone.now,
        ip_address: request.remote_ip,
        user_agent: request.user_agent
      )
    end

    render json: { success: true }
  end

  def health_goals
    health_goals = params.permit(
      :general_health,
      :live_longer,
      :manage_weight,
      :slow_aging,
      :optimize_athletic_performance,
      :manage_condition,
      :navigate_system,
      :answer_health_questions,
      :other,
      :other_text
    )
    @current_user.update!(health_goals: health_goals)

    render json: { success: true }
  end
end