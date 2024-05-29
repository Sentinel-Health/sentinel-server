class InternalApi::V1::AllergiesController < InternalApi::V1::BaseController
  def index
    allergies = active_allergies
    render json: {
      allergies: allergies.map { |allergy| AllergyJson.new(allergy).call }
    }
  end

  def show
    allergy = @current_user.allergies.find(params[:id])
    render json: AllergyJson.new(allergy).call
  end

  def related_conversations
    allergy = @current_user.allergies.find(params[:id])
    conversations = Message.get_related_conversations(@current_user.id, allergy.name)
    render json: conversations.map { |conversation| ConversationJson.new(conversation).call }
  end

  def archive
    allergy = @current_user.allergies.find(params[:id])
    allergy.update!(is_archived: true, archived_at: Time.now)
    allergies = active_allergies
    render json: {
      allergies: allergies.map { |allergy| AllergyJson.new(allergy).call }
    }
  end

  private

  def active_allergies
    @current_user.allergies.active.order(recorded_on: :desc)
  end
end