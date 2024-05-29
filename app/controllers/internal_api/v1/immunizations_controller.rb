class InternalApi::V1::ImmunizationsController < InternalApi::V1::BaseController
  def index
    immunizations = active_immunizations
    render json: {
      immunizations: immunizations.map { |immunization| ImmunizationJson.new(immunization).call }
    }
  end

  def show
    immunization = @current_user.immunizations.find(params[:id])
    render json: ImmunizationJson.new(immunization).call
  end

  def related_conversations
    immunization = @current_user.immunizations.find(params[:id])
    conversations = Message.get_related_conversations(@current_user.id, immunization.name)
    render json: conversations.map { |conversation| ConversationJson.new(conversation).call }
  end

  def archive
    immunization = @current_user.immunizations.find(params[:id])
    immunization.update!(is_archived: true, archived_at: Time.now)
    immunizations = active_immunizations
    render json: {
      immunizations: immunizations.map { |immunization| ImmunizationJson.new(immunization).call }
    }
  end

  private

  def active_immunizations
    @current_user.immunizations.active.order(received_on: :desc)
  end
end