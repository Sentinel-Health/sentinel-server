module FhirData
  extend ActiveSupport::Concern

  class_methods do
    def get_vaccine_name_from_cvx_code(vaccine_code)
      cvx_code = vaccine_code.to_i
      return nil if cvx_code.blank?
      file_path = Rails.root.join('lib', 'data', 'cvx_codes.json')
      cvx_codes = JSON.parse(File.read(file_path))
      vaccine_data = cvx_codes.find { |vaccine| vaccine['code'] == cvx_code }
      return nil if vaccine_data.blank?
      vaccine_data['short_description']
    end

    def get_immunization_data_from_fhir_data(fhir_data, fhir_release)
      return nil if fhir_data.blank?

      text = fhir_data.dig('vaccineCode', 'text')
      display = fhir_data.dig('vaccineCode', 'coding', 0, 'display')
      vaccine_code = fhir_data.dig('vaccineCode', 'coding', 0, 'code')
      if fhir_release == 'DSTU2'
        received_date = fhir_data.dig('date')
      else
        received_date = fhir_data.dig('occurrenceDateTime')
      end

      name = text || display
      vaccine_name = !name.blank? ? name : get_vaccine_name_from_cvx_code(vaccine_code)

      return {
        name: vaccine_name,
        received_date: received_date,
      }
    end

    def get_allergy_data_from_fhir_data(fhir_data, fhir_release)
      return nil if fhir_data.blank?

      if fhir_release == 'DSTU2'
        text = fhir_data.dig('substance', 'text')
        display = fhir_data.dig('substance', 'coding', 0, 'display')
        status = fhir_data.dig('status')
      else
        text = fhir_data.dig('code', 'text')
        display = fhir_data.dig('code', 'coding', 0, 'display')
        status = fhir_data.dig('clinicalStatus', 'coding', 0, 'code')
      end
      name = text || display
      recorded_date = fhir_data.dig('recordedDate') || fhir_data.dig('onset')

      return {
        name: name,
        recorded_date: recorded_date,
        status: status,
      }
    end

    def get_medication_data_from_fhir_data(fhir_data, fhir_release)
      return nil if fhir_data.blank?

      if fhir_release == 'DSTU2'
        text = fhir_data.dig('medicationCodeableConcept', 'text')
        display = fhir_data.dig('medicationCodeableConcept', 'coding', 0, 'display')
        authored_on = fhir_data.dig('dateWritten')
        authored_by = fhir_data.dig('prescriber', 'display')
      else
        display = fhir_data.dig('medicationReference', 'display')
        text = fhir_data.dig('contained', 0, 'code', 'text')
        authored_on = fhir_data.dig('authoredOn')
        authored_by = fhir_data.dig('requester', 'display')
      end
      name = display || text
      status = fhir_data.dig('status')
      dosage_instructions = fhir_data.dig('dosageInstruction', 0, 'patientInstruction') || fhir_data.dig('dosageInstruction', 0, 'text')

      return {
        name: name.strip,
        status: status,
        authored_on: authored_on,
        dosage_instructions: dosage_instructions,
        authored_by: authored_by
      }
    end

    def get_procedure_data_from_fhir_data(fhir_data)
      return nil if fhir_data.blank?

      text = fhir_data.dig('code', 'text')
      display = fhir_data.dig('code', 'coding', 0, 'display')
      name = text || display
      performed_date = fhir_data.dig('performedDateTime') ||  fhir_data.dig('performedPeriod', 'start')
      status = fhir_data.dig('status')

      return {
        name: name,
        performed_date: performed_date,
        status: status,
      }
    end

    def get_condition_data_from_fhir_data(fhir_data, fhir_release)
      return nil if fhir_data.blank?

      text = fhir_data.dig('code', 'text')
      display = fhir_data.dig('code', 'coding', 0, 'display')
      name = text || display
      recorded_date = fhir_data.dig('recordedDate') || fhir_data.dig('dateRecorded')
      recorded_by = fhir_data.dig('asserter', 'display') || fhir_data.dig('recorder', 'display')
      if fhir_release == 'DSTU2'
        clinical_status = fhir_data.dig('clinicalStatus')
        verification_status = fhir_data.dig('verificationStatus')
      else
        clinical_status = fhir_data.dig('clinicalStatus', 'coding', 0, 'display')
        verification_status = fhir_data.dig('verificationStatus', 'coding', 0, 'display')
      end

      return {
        name: name.strip,
        recorded_date: recorded_date,
        recorded_by: recorded_by,
        clinical_status: clinical_status,
        verification_status: verification_status,
      }
    end

    def get_lab_result_data_from_fhir_data(fhir_data)
      return nil if fhir_data.blank?
  
      text = fhir_data.dig('code', 'text')
      display = fhir_data.dig('code', 'coding', 0, 'display')
      name = text || display
      issued = fhir_data['effectiveDateTime'] || fhir_data['issued']
  
      value_data = get_value_from_observation(fhir_data)
      value = value_data[:value]
      value_unit = value_data[:unit]
      value_string = value_data[:value_string]
  
      reference_range_data = get_reference_range_from_observation(fhir_data)
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
  
    def get_value_from_observation(fhir_data)
      valueQuantity = fhir_data.dig('valueQuantity')
      valueCodeableConcept = fhir_data.dig('valueCodeableConcept')
      valueString = fhir_data.dig('valueString')
      valueBoolean = fhir_data.dig('valueBoolean')
      valueInteger = fhir_data.dig('valueInteger')
      valueRange = fhir_data.dig('valueRange')
      valueRatio = fhir_data.dig('valueRatio')
      valueSampledData = fhir_data.dig('valueSampledData')
      valueTime = fhir_data.dig('valueTime')
      valueDateTime = fhir_data.dig('valueDateTime')
      valuePeriod = fhir_data.dig('valuePeriod')
  
      if valueQuantity.present?
        return {
          value: valueQuantity['value'],
          unit: valueQuantity['unit'],
          value_string: "#{valueQuantity['value'].to_s}#{valueQuantity['unit']}"
        }
      elsif valueCodeableConcept.present?
        return {
          value: nil,
          unit: nil,
          value_string: valueCodeableConcept['text']
        }
      elsif valueString.present?
        # Check if the value is a number or number range, like ">=10", "<0.01", "<20", "4", etc.
        if match_data = valueString.match(/([<>]=?)(\d+(\.\d+)?)/)
          value = match_data[2].to_f
          return {
            value: value,
            unit: nil,
            value_string: valueString
          }
        else
          return {
            value: nil,
            unit: nil,
            value_string: valueString
          }
        end
      elsif valueBoolean.present?
        return {
          value: nil,
          unit: nil,
          value_string: valueBoolean.to_s
        }
      elsif valueInteger.present?
        return {
          value: valueInteger,
          unit: nil,
          value_string: valueInteger.to_s
        }
      elsif valueRange.present?
        high = fhir_data.dig(valueRange, 'high', 'value')
        high_unit = fhir_data.dig(valueRange, 'high', 'unit')
        low = fhir_data.dig(valueRange, 'low', 'value')
        low_unit = fhir_data.dig(valueRange, 'low', 'unit')

        if low.present? && high.present?
          text = "#{low}#{low_unit} - #{high}#{high_unit}"
        elsif low.present? || high.present?
          text = low.present? ? "≥#{low['value']}#{low['unit']}" : "≤#{high['value']}#{high['unit']}"
        else
          text = "#{low}#{low_unit} - #{high}#{high_unit}"
        end
  
        return {
          value: nil,
          unit: low_unit,
          value_string: text
        }
      elsif valueRatio.present?
        numerator = fhir_data.dig(valueRatio, 'numerator', 'value')
        numerator_unit = fhir_data.dig(valueRatio, 'numerator', 'unit')
        denominator = fhir_data.dig(valueRatio, 'denominator', 'value')
        denominator_unit = fhir_data.dig(valueRatio, 'denominator', 'unit')
  
        return {
          value: numerator / denominator,
          unit: numerator_unit,
          value_string: "#{numerator}#{numerator_unit} / #{denominator}#{denominator_unit}"
        }
      elsif valueSampledData.present?
        origin = fhir_data.dig(valueSampledData, 'origin', 'value')
        origin_unit = fhir_data.dig(valueSampledData, 'origin', 'unit')
        period = fhir_data.dig(valueSampledData, 'period')
        factor = fhir_data.dig(valueSampledData, 'factor')
        lower_limit = fhir_data.dig(valueSampledData, 'lowerLimit')
        upper_limit = fhir_data.dig(valueSampledData, 'upperLimit')
        dimensions = fhir_data.dig(valueSampledData, 'dimensions')
  
        return {
          value: origin,
          unit: origin_unit,
          value_string: "#{origin}#{origin_unit} #{period} #{factor} #{lower_limit} #{upper_limit} #{dimensions}"
        }
      elsif valueTime.present?
        return {
          value: nil,
          unit: nil,
          value_string: valueTime
        }
      elsif valueDateTime.present?
        return {
          value: nil,
          unit: nil,
          value_string: valueDateTime
        }
      elsif valuePeriod.present?
        start_date = fhir_data.dig(valuePeriod, 'start')
        end_date = fhir_data.dig(valuePeriod, 'end')
  
        return {
          value: nil,
          unit: nil,
          value_string: "#{start_date} - #{end_date}"
        }
      else
        return {
          value: nil,
          unit: nil,
          value_string: nil
        }
      end
    end
  
    def get_reference_range_from_observation(fhir_data)
      low = fhir_data.dig('referenceRange', 0, 'low')
      high = fhir_data.dig('referenceRange', 0, 'high')
      text = fhir_data.dig('referenceRange', 0, 'text')
  
      if low.present? && high.present?
        return {
          reference_range: {
            low: low['value'],
            low_unit: low['unit'],
            high: high['value'],
            high_unit: high['unit']
          },
          reference_range_string: "#{low['value']}#{low['unit']} - #{high['value']}#{high['unit']}"
        }
      elsif low.present? || high.present?
        text = low.present? ? "≥#{low['value']}#{low['unit']}" : "≤#{high['value']}#{high['unit']}"

        return {
          reference_range: {
            low: low.present? ? low['value'] : 0,
            low_unit: low.present? ? low['unit'] : high['unit'],
            high: high.present? ? high['value'] : nil,
            high_unit: high.present? ? high['unit'] : low['unit']
          },
          reference_range_string: text
        }
      elsif text.present?
        # Attempt to parse the reference range from the text
        if match_data = text.match(/([<>]=?)(\d+(\.\d+)?)/)
          value = match_data[2].to_f
          symbol = match_data[1]

          if symbol.include?('<')
            return {
              reference_range: { low: 0, low_unit: '', high: value, high_unit: '' },
              reference_range_string: text
            }
          else
            return {
              reference_range: { low: value, low_unit: '', high: nil, high_unit: '' },
              reference_range_string: text
            }
          end
        else
          return {
            reference_range: nil,
            reference_range_string: text
          }
        end
      else
        return {
          reference_range: nil,
          reference_range_string: nil
        }
      end
    end
  end
end