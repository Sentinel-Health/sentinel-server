class InternalApi::V1::MedicationsController < InternalApi::V1::BaseController
  def index
    medications = active_medications
    render json: {
      medications: medications.map { |medication| MedicationJson.new(medication).call }
    }
  end

  def show
    medication = @current_user.medications.find(params[:id])
    render json: MedicationJson.new(medication).call
  end

  def related_conversations
    medication = @current_user.medications.find(params[:id])
    conversations = Message.get_related_conversations(@current_user.id, medication.name)
    render json: conversations.map { |conversation| ConversationJson.new(conversation).call }
  end

  def archive
    medication = @current_user.medications.find(params[:id])
    medication.update!(is_archived: true, archived_at: Time.now)
    medications = active_medications
    render json: {
      medications: medications.map { |medication| MedicationJson.new(medication).call }
    }
  end

  private

  def active_medications
    @current_user.medications.active.order(authored_on: :desc)
  end
end