module UnitConversionService
  extend ActiveSupport::Concern

  GPT_MODEL = "gpt-4o"
  MAX_RETRY_COUNT = 3

  class_methods do
    def convert_units_gpt(value, value_units, units, retry_count = 0)
      response = $openai.chat(
        parameters: {
          model: GPT_MODEL,
          messages: [
            {
              role: "system",
              content: "You are a helpful medical assistant. Your job is to help convert between units of lab results. You will be given the type of result that the conversion is for, the units to convert from, and the units to convert to. If there isn't one answer or you do not know the answer, provide the most likely answer. If they are equal, just multiply the value by 1.

Think about it step by step. 

Here are known conversions to help:
- th/cmm to K/uL -> 1:1
- uIU/mL to mIU/L -> 1:1
- mil/cmm to M/uL -> 1:1
- Million/uL to M/uL -> 1:1
              
The entire response should be in valid JSON format, like the following:
{
  \"operator\": \"*\",
  \"quantity\": 1000,
}"
            }, {
              role: "user",
              content: "convert \"#{value_units}\" to \"#{units}\""
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
        if response.dig("error", "code") == "rate_limit_exceeded"
          # Retry in 5 seconds
          sleep(5)
          retry_count += 1
          if retry_count < MAX_RETRY_COUNT
            return convert_units(value_string, units, retry_count)
          else
            raise "OpenAI rate limit exceeded after 5 retries"
          end
        else 
          raise "#{response.dig("error", "message")}"
        end
      end

      message = response.dig("choices", 0, "message", "content")
      conversion = JSON.parse(message)
      conversion
    end

    def convert_units(value, value_units, units)
      value_units = value_units.gsub("(calc)", "")
      value_units = value_units.strip

      if value_units == units
        return {
          "value" => value,
          "unit" => units,
        }
      end

      conversion = Rails.cache.fetch("unit_conversion/#{value_units}/#{units}") do
        convert_units_gpt(value, value_units, units)
      end

      if conversion["operator"] == "*"
        value = value.to_f * conversion["quantity"]
      elsif conversion["operator"] == "/"
        value = value.to_f / conversion["quantity"]
      end

      return {
        "value" => value,
        "unit" => units,
      }
    end
  end
end