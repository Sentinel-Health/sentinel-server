class InternalApi::V1::ChatFeedbackController < InternalApi::V1::BaseController
  def create
    chat_feedback = ChatFeedback.create!(
      user: @current_user,
      message_id: params[:message_id],
      feedback_type: params[:feedback_type],
    )

    render json: {
      success: true,
    }
  end
end