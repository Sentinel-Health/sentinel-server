class InternalApi::V1::ChatSuggestionsController < InternalApi::V1::BaseController
  def index
    chat_suggestions = @current_user.chat_suggestions.where(was_used: false).order('RANDOM()').limit(5)

    render json: {
      suggestions: chat_suggestions.map { |suggestion| ChatSuggestionJson.new(suggestion).call },
    }
  end

  def suggestion_used
    chat_suggestion = @current_user.chat_suggestions.find(params[:id])
    chat_suggestion.update(was_used: true)

    # TODO: in the future, create a new chat suggestion when one is used

    render json: {
      success: true,
    }
  end
end