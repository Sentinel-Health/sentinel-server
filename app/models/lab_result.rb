class LabResult < ApplicationRecord
  include FhirData
  include VitalLabResultsData
  include UnitConversionService
  include VectorDbService

  belongs_to :user,  touch: true
  belongs_to :clinical_record, optional: true
  belongs_to :lab_test_order, optional: true
  belongs_to :biomarker, optional: true

  after_create :vector_database_upsert
  after_update :vector_database_upsert
  after_destroy :remove_from_vector_database

  validates :name, presence: true

  scope :most_recent_for_user, ->(user_id) { 
    where("lab_results.issued = (
      SELECT MAX(issued) 
      FROM lab_results 
      WHERE lab_results.biomarker_id = lab_results.biomarker_id 
      AND lab_results.user_id = ?)", user_id) 
  }

  scope :all_most_recent_for_user, ->(user_id) {
    joins(sanitize_sql(["INNER JOIN (
      SELECT DISTINCT ON (biomarker_id) biomarker_id, issued AS latest_issued, id AS max_id
      FROM lab_results
      WHERE user_id = ?
      ORDER BY biomarker_id, issued DESC, id DESC
      ) AS latest_samples 
        ON lab_results.biomarker_id = latest_samples.biomarker_id 
        AND lab_results.issued = latest_samples.latest_issued 
        AND lab_results.id = latest_samples.max_id", user_id]))
    .where('lab_results.user_id = ?', user_id)
  }

  scope :most_recent_out_of_range_for_user, ->(user_id) { 
    most_recent_for_user(user_id).out_of_range_for_user(user_id) 
  }
  scope :all_most_recent_out_of_range_for_user, ->(user_id) { 
    all_most_recent_for_user(user_id).out_of_range_for_user(user_id) 
  }

  scope :out_of_range_for_user, ->(user_id) { 
    where("(
      (lab_results.reference_range_json->>'low' IS NOT NULL AND lab_results.value_quantity < (lab_results.reference_range_json->>'low')::float) OR
      (lab_results.reference_range_json->>'low' IS NULL AND lab_results.value_quantity > (lab_results.reference_range_json->>'high')::float) OR
      (lab_results.reference_range_json->>'high' IS NOT NULL AND lab_results.value_quantity > (lab_results.reference_range_json->>'high')::float) OR
      (lab_results.reference_range_json->>'high' IS NULL AND lab_results.value_quantity < (lab_results.reference_range_json->>'low')::float)
    )")
    .joins(:biomarker)
    .where(user_id: user_id) 
  }

  def will_save_change_to_issued_on?
    will_save_change_to_attribute?(:issued)
  end

  def self.create_from_clinical_record(user_id, clinical_record)
    lab_result_data = get_lab_result_data_from_fhir_data(clinical_record.fhir_data)
    unless lab_result_data.present?
      AdminMailer.with(data_source: "Clinical Record", context: {
        clinical_record_id: clinical_record.id,
        user_id: clinical_record.user_id,
        data_type: "clinical_record",
      }).missing_result_data.deliver_later

      return
    end

    lab_result = self.find_or_initialize_by(user_id: user_id, clinical_record_id: clinical_record.id)

    lab_result.name = lab_result_data[:name]
    lab_result.issued = lab_result_data[:issued]

    lab_result.value = lab_result_data[:value_string]
    lab_result.value_quantity = lab_result_data[:value]
    lab_result.unit = lab_result_data[:value_unit]

    lab_result.reference_range_json = lab_result_data[:reference_range]
    lab_result.reference_range = lab_result_data[:reference_range_string]

    biomarker = self.find_related_biomarker(lab_result_data[:name])
    if biomarker.present?
      lab_result.biomarker_id = biomarker.id
    end

    lab_result.save
    return lab_result
  end

  def self.create_from_vital_result(user_id, vital_data, lab_test_order)
    lab_result_data = get_lab_result_data_from_vital_data(vital_data)
    unless lab_result_data.present?
      AdminMailer.with(data_source: "Vital", context: {
        lab_test_order_id: lab_test_order.id,
        vital_order_id: lab_test_order.vital_order_id,
        user_id: user_id,
        data_type: "vital_result",
      }).missing_result_data.deliver_later
      return nil, false
    end

    lab_result = self.find_or_initialize_by(user_id: user_id, name: lab_result_data[:name], lab_test_order_id: lab_test_order.id)

    lab_result.issued = lab_result_data[:issued]

    lab_result.value = lab_result_data[:value_string]
    lab_result.value_quantity = lab_result_data[:value]
    lab_result.unit = lab_result_data[:value_unit]

    lab_result.reference_range_json = lab_result_data[:reference_range]
    lab_result.reference_range = lab_result_data[:reference_range_string]

    biomarker = self.find_related_biomarker(lab_result_data[:name])
    if biomarker.present?
      lab_result.biomarker_id = biomarker.id
    end

    is_new = lab_result.new_record?
    lab_result.save
    return lab_result, is_new
  end

  def vector_metadata
    {
      lab_result_id: self.id,
      user_id: self.user_id,
      name: name || "",
      value: value || "",
      issued: issued.nil? ? 0 : issued.to_i,
      reference_range: reference_range || "",
      source: self.clinical_record ? self.clinical_record.source_name : self.lab_test_order.lab_test.lab.name,
    }
  end

  def vector_database_upsert
    save_in_vector_db("lab_results", id, name, vector_metadata)
  end

  def remove_from_vector_database
    delete_from_vector_db("lab_results", self.id)
  end

  def self.vector_database_batch_upsert
    vectors = []
    self.find_each(batch_size: 100) do |lab_result|
      vectors << {
        id: lab_result.id,
        metadata: lab_result.vector_metadata,
        values: VectorDbService.get_embedding(lab_result.name)
      }

      if vectors.size >= 100
        batch_upsert_in_vector_db("lab_results", vectors)
        vectors.clear
      end
    end

    batch_upsert_in_vector_db("lab_results", vectors) unless vectors.empty?
  end

  def self.search_embeddings(user_id, query, offset = 0, filter = {}, k = 10)
    if query.present? && query != ''
      if filter.present?
        if filter[:start_date].present? || filter[:end_date].present?
          # Get the start of the day for the start_date and the end of the day for the end_date
          start_date = filter[:start_date].present? ? filter[:start_date].to_time.beginning_of_day.to_i : 0
          end_date = filter[:end_date].present? ? filter[:end_date].to_time.end_of_day.to_i : Time.now.to_i

          filter = {
            "$and": [
              { "issued": { "$gte": start_date } },
              { "issued": { "$lte": end_date } },
            ]
          }
        end
      else 
        filter = {}
      end

      results = query_vector_db("lab_results", user_id, query, offset, filter, k)
      return results.map do |result|
        {
          score: result[:score],
          data: {
            id: result.dig(:data, :lab_result_id),
            name: result.dig(:data, :name),
            value: result.dig(:data, :value),
            issued: result.dig(:data, :issued).present? ? Time.at(result.dig(:data, :issued)).to_date : nil,
            reference_range: result.dig(:data, :reference_range),
            source: result.dig(:data, :source),
          }
        }
      end
    else
      results = []
      page = offset + 1

      if filter.present?
        if filter[:start_date].present? || filter[:end_date].present?
          # Get the start of the day for the start_date and the end of the day for the end_date
          start_date = filter[:start_date].present? ? filter[:start_date].to_time.beginning_of_day : (Time.now - 50.years).beginning_of_day
          end_date = filter[:end_date].present? ? filter[:end_date].to_time.end_of_day : Time.now

          results = self.where(user_id: user_id).where("issued >= ? AND issued <= ?", start_date, end_date).order(issued: :desc).page(page).per(k)
        else
          results = self.where(user_id: user_id).order(issued: :desc).page(page).per(k)
        end
      else
        results = self.where(user_id: user_id).order(issued: :desc).page(page).per(k)
      end

      return {
        results: results.map do |result|
          {
            name: result.name,
            value: result.value,
            issued: result.issued.to_date,
            reference_range: result.reference_range,
          }
        end,
        total_results: results.total_count,
      }
    end
  end

  def self.find_related_biomarker(name)
    return Biomarker.find_by_biomarker_name(name)
  end

  def get_converted_units_for_biomarker
    if unit.present? && unit != biomarker.unit
      puts "Need to convert units for #{name} from #{unit} to #{biomarker.unit}"
      conversion_results = convert_units(value_quantity, unit, biomarker.unit)
      converted_value = conversion_results["value"]
      converted_unit = conversion_results["unit"]
      return {
        value_quantity: converted_value,
        unit: converted_unit,
        value: "#{converted_value}#{converted_unit}"
      }
    else
      return {
        value_quantity: value_quantity,
        unit: unit,
        value: "#{value}#{unit}"
      }
    end
  end
end
