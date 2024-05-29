require_dependency 'open_ai_error'

module SummaryService
  extend ActiveSupport::Concern

  SUMMARY_MODEL = "gpt-4o"
  BACKUP_MODEL = "gpt-4-turbo"

  included do
    def get_conversation_title(prompt)
      model = SUMMARY_MODEL
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
                  content: "You are a helpful assistant. Your job is to come up with a title that summarizes what this conversation is about. The title should only be a few words long. If you cannot come up with a title, respond with \"New conversation
                  \"."
                }, {
                  role: "user",
                  content: prompt
                }
              ],
              temperature: 0,
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
          return message
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

    def get_summary(prompt)
      model = SUMMARY_MODEL
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
                  content: "You are a helpful medical assistant. Your job is to summarize the information for a user that is provided to you in a way that conveys the most important information that a doctor should know about the particular subject and the information available. Please keep this summary as concise as possible, but do not leave out any important information. Do not include any additional information outside of the summary. If no information is available, respond with \"No information available\"."
                }, {
                  role: "user",
                  content: prompt
                }
              ],
              temperature: 0,
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
          return message, model
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