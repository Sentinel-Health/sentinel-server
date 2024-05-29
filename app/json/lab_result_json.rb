class LabResultJson
  def initialize(lab_result, format = :short)
    @lab_result = lab_result
    @format = (format || :short).to_s.to_sym
  end

  def call(options=nil)
    return to_json(@lab_result, options) unless @lab_result.respond_to?(:each)
    @lab_result.map { |lab_result| to_json(lab_result, options) }
  end

  private

  def to_json(lab_result, options)
    return nil unless lab_result
    Rails.cache.fetch("json/v1.1/#{lab_result.cache_key_with_version}/#{@format.to_s}") do
      case @format
      when :full
        full_json(lab_result, options)
      else
        short_json(lab_result, options)
      end
    end
  end

  def short_json(lab_result, options)
    return nil if lab_result.nil?
    json_data = {
      id: lab_result.id,
      name: lab_result.name,
      issued: lab_result.issued,
      value: lab_result.value_quantity,
      valueString: lab_result.value,
      valueUnit: lab_result.unit,
      referenceRangeString: lab_result.reference_range,
      source: lab_result.clinical_record ? lab_result.clinical_record.source_name : lab_result.lab_test_order.lab_test.lab.name,
    }
    
    if lab_result.reference_range_json
      json_data[:referenceRange] = {
        low: lab_result.reference_range_json["low"],
        high: lab_result.reference_range_json["high"]
      }
    end

    json_data
  end

  def full_json(lab_result, options)
    return nil if lab_result.nil?
    {
      **short_json(lab_result, options),
      biomarker: BiomarkerJson.new(lab_result.biomarker).call
    }
  end
end