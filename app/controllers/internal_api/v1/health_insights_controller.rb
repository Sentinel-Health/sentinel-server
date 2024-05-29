class InternalApi::V1::HealthInsightsController < InternalApi::V1::BaseController
  def index
    if params[:category].blank?
      health_insights = @current_user.health_insights.order(created_at: :desc).first
    else
      health_insights = @current_user.health_insights.where(category: params[:category]).order(created_at: :desc).first
    end

    health_insights_json = HealthInsightJson.new(health_insights).call.to_json
    render json: health_insights_json
  end
end