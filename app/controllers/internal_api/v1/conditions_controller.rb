class InternalApi::V1::ConditionsController < InternalApi::V1::BaseController
  def index
    conditions = active_conditions
    render json: {
      conditions: conditions.map { |condition| ConditionJson.new(condition).call }
    }
  end

  def show
    condition = @current_user.conditions.find(params[:id])
    render json: ConditionJson.new(condition).call
  end

  def related_conversations
    condition = @current_user.conditions.find(params[:id])
    conversations = Message.get_related_conversations(@current_user.id, condition.name)
    render json: conversations.map { |conversation| ConversationJson.new(conversation).call }
  end

  def archive
    condition = @current_user.conditions.find(params[:id])
    condition.update!(is_archived: true, archived_at: Time.now)
    conditions = active_conditions
    render json: {
      conditions: conditions.map { |condition| ConditionJson.new(condition).call }
    }
  end

  private

  def active_conditions
    conditions = @current_user.conditions.active
                                .joins("LEFT JOIN condition_histories ON conditions.id = condition_histories.condition_id")
                                .select("conditions.*, MAX(condition_histories.recorded_on) as most_recent_history_date")
                                .group('conditions.id')
                                .order('most_recent_history_date DESC NULLS LAST, conditions.updated_at DESC')
  end
end