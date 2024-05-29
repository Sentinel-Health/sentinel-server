class InternalApi::V1::ProceduresController < InternalApi::V1::BaseController
  def index
    procedures = active_procedures
    render json: {
      procedures: procedures.map { |procedure| ProcedureJson.new(procedure).call }
    }
  end

  def show
    procedure = @current_user.procedures.find(params[:id])
    render json: ProcedureJson.new(procedure).call
  end

  def related_conversations
    procedure = @current_user.procedures.find(params[:id])
    conversations = Message.get_related_conversations(@current_user.id, procedure.name)
    render json: conversations.map { |conversation| ConversationJson.new(conversation).call }
  end

  def archive
    procedure = @current_user.procedures.find(params[:id])
    procedure.update!(is_archived: true, archived_at: Time.now)
    procedures = active_procedures
    render json: {
      procedures: procedures.map { |procedure| ProcedureJson.new(procedure).call }
    }
  end

  private

  def active_procedures
    @current_user.procedures.active.order(performed_on: :desc)
  end
end