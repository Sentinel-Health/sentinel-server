require_dependency 'open_ai_error'

module ChatSuggestionsService
  extend ActiveSupport::Concern

  MODEL = "gpt-4o"
  BACKUP_MODEL = "gpt-4-turbo"

  included do
    def get_chat_suggestions(prompt, num_of_suggestions = 5)
      model = MODEL
      attempts = 0
      Retriable.retriable(
        on: [OpenAiError::RateLimit, OpenAiError::ServerError, OpenAiError::ServerOverloaded],
        tries: 5
      ) do
        attempts += 1

        begin
          response = $openai.chat(
            parameters: {
              model: model,
              messages: [
                {
                  role: "system",
                  content: "You are a helpful healthcare assistant. Your job is to come up with #{num_of_suggestions} potential chat prompts in which a user could use to start a conversation with you. The prompts should also come with a title that summarizes the prompt in a few words and a description that provides a one sentence description about the prompt. This title and description will be displayed to the user so that they can decide which prompt to use, they should not be in the first person. The prompt should be written as if it's coming from the user.

You will be provided with some of the user's health data, as well as prior prompts they've been given. Use this information to come up with new  prompts that are either relevant to the user's health data or that are good general health prompts, like questions to ask a doctor, health care plan strategies, how to evaluate health insurance plans, etc.

The prompts should be original and not repeat previous generated prompts.

Your response should be in valid JSON format ONLY. For example: 
              
{
  \"prompts\": [
    {
      \"title\": \"A few words title\",
      \"description\": \"A few more details about the prompt.\",
      \"prompt\": \"I'd like to talk about my health care.\"
    }, {
      \"title\": \"Different prompt title\",
      \"description\": \"More details about this prompt.\",
      \"prompt\": \"What questions should I ask my doctor the next time I see them?\"
    },
    ... 
  ]
}"
                }, {
                  role: "user",
                  content: prompt
                }
              ],
              temperature: 1.0,
              response_format: {
                type: "json_object"
              }
            }
          )

          if response.dig("error").present?
            error_code = response.dig("error", "code")
            if error_code == 429 && attempts > 3
              model = BACKUP_MODEL
              raise OpenAiError::RateLimit.new(response.dig("error", "message"))
            elsif error_code == 401
              raise OpenAiError::Unauthorized.new(response.dig("error", "message"))
            elsif error_code == 400
              raise OpenAiError::BadRequest.new(response.dig("error", "message"))
            elsif error_code == 500
              raise OpenAiError::ServerError.new(response.dig("error", "message"))
            elsif error_code == 503
              raise OpenAiError::ServerOverloaded.new(response.dig("error", "message"))
            else
              raise OpenAiError::Error.new(response.dig("error", "message"))
            end
          end

          message = response.dig("choices", 0, "message", "content")
          json_message = JSON.parse(message)
          return json_message["prompts"], model
        rescue Faraday::Error => e
          if e.response_status == 429 && attempts > 3
            model = BACKUP_MODEL
            raise OpenAiError::RateLimit.new(e.message)
          elsif e.response_status == 401
            raise OpenAiError::Unauthorized.new(e.message)
          elsif e.response_status == 400
            raise OpenAiError::BadRequest.new(e.message)
          elsif e.response_status == 500
            raise OpenAiError::ServerError.new(e.message)
          elsif e.response_status == 503
            raise OpenAiError::ServerOverloaded.new(e.message) 
          else 
            raise OpenAiError::Error.new(e.message)
          end
        end
      end
    end
  end
end