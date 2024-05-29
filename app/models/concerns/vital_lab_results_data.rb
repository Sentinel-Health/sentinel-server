module VitalLabResultsData
  extend ActiveSupport::Concern

  class_methods do
    def get_lab_result_data_from_vital_data(vital_data)
      return nil if vital_data.blank?

      name = vital_data.dig('name')
      issued = vital_data.dig('timestamp') || Time.now
  
      value_data = get_value_from_result(vital_data)
      value = value_data[:value]
      value_unit = value_data[:unit]
      value_string = value_data[:value_string]

      reference_range_data = get_reference_range_from_result(vital_data)
      reference_range = reference_range_data[:reference_range]
      reference_range_string = reference_range_data[:reference_range_string]
  
      if name.blank? || (value.blank? && value_string.blank?)
        Rails.logger.info "Skipping lab result because of missing data"
        return nil
      end

      return {
        name: name,
        issued: issued,
        value: value,
        value_unit: value_unit,
        value_string: value_string,
        reference_range: reference_range,
        reference_range_string: reference_range_string
      }
    end

    def get_value_from_result(result_data)
      value_type = result_data.dig('type')

      value_type = result_data.dig('type')
      case value_type
      when 'numeric'
        value = result_data.dig('result').to_f
        value_unit = result_data.dig('unit')
        value_string = "#{value} #{value_unit}"

        return {
          value: value,
          unit: value_unit,
          value_string: value_string
        }
      when 'range'
        value_string = result_data.dig('result')
        value_unit = result_data.dig('unit')

        # Extract value from string, like "<10" or ">20" or ">=0.5"
        value = value_string.match(/([<>]=?)(\d+(\.\d+)?)/).try(:[], 2).to_f
  
        return {
          value: value,
          unit: value_unit,
          value_string: value_string
        }
      when 'comment'
        value = result_data.dig('result')
        value_unit = result_data.dig('unit')

        return {
          value: nil,
          unit: value_unit,
          value_string: value
        }
      else
        error_message = "Unknown value type for vital data: #{value_type}"
        Rails.logger.error error_message
        Sentry.capture_message(error_message)
        return {
          value: nil,
          unit: nil,
          value_string: nil
        }
      end
    end

    def get_reference_range_from_result(result_data)
      low = result_data.dig('min_range_value')
      high = result_data.dig('max_range_value')
      value_unit = result_data.dig('unit')
  
      if low.present? && high.present?
        return {
          reference_range: {
            low: low,
            low_unit: value_unit,
            high: high,
            high_unit: value_unit
          },
          reference_range_string: "#{low}#{value_unit} - #{high}#{value_unit}"
        }
      elsif low.present? || high.present?
        text = low.present? ? "≥#{low}#{value_unit}" : "≤#{high}#{value_unit}"

        return {
          reference_range: {
            low: low.present? ? low : 0,
            low_unit: value_unit,
            high: high,
            high_unit: value_unit
          },
          reference_range_string: text
        }
      else
        return {
          reference_range: nil,
          reference_range_string: nil
        }
      end
    end

  end

end