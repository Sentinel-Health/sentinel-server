module HealthInsightsService
  extend ActiveSupport::Concern

  MODEL = "gpt-4o"

  included do
    def get_health_insights(prompt)
      response = $openai.chat(
        parameters: {
          model: MODEL,
          messages: [
            {
              role: "system",
              content: "You are a helpful healthcare assistant. Your job is to provide users with advice and suggestions about their health given some health data.

Your response should be friendly and upbeat. Don't use a salutation to start.

You're not to diagnose anything but rather provide suggestions for how they might be able to improve their health, given the results. You can make suggestions to talk to a doctor or other healthcare professional, but the user perfers more actionable advice that they can do on their own.

Please provide one sentence to summarize, at most 3-5 things the user can do to improve their health, and for each improvement a prompt to start a chat conversation about it. The chat prompt should be written as if it's coming from the user.

If there is no data provided, you can return null for each field. If everything is looking good, don't be afraid to tell the user this and encourage them to keep it up by providing suggestions for how they can continue to improve their health.

The user prefers short and concise responses. Your response should be in valid JSON format ONLY. For example: 
              
{
  \"short_summary\": \"One sentence summary.\",
  \"suggestions\": [{
    \"suggestion\": \"Suggestion 1.\",
    \"chat_prompt\": \"I'd like to talk about suggestion 1.\"
  }, {
    \"suggestion\": \"Suggestion 2.\",
    \"chat_prompt\": \"Can you tell me more about suggestion 2?\"
  },
    ... 
  ],
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
        Rails.logger.error("OpenAI error: #{response.dig("error", "message")}")
        raise "#{response.dig("error", "message")}"
      end

      message = response.dig("choices", 0, "message", "content")
      json_message = JSON.parse(message)
      json_message
    end
  end
end