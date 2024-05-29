class Medication < ApplicationRecord
  belongs_to :user
  belongs_to :clinical_record

  after_create :vector_database_upsert
  after_update :vector_database_upsert, :update_medication_summary
  after_destroy :remove_from_vector_database

  scope :active, -> { where(status: 'active', is_archived: false) }

  def source
    clinical_record.source_name
  end

  include FhirData
  def self.create_from_clinical_record(user_id, clinical_record)
    medication_data = get_medication_data_from_fhir_data(clinical_record.fhir_data, clinical_record.fhir_release)
    return unless medication_data.present?

    medication = self.find_or_initialize_by(user_id: user_id, clinical_record_id: clinical_record.id)
    medication.name = medication_data[:name]
    medication.status = medication_data[:status].present? ? medication_data[:status].downcase : nil
    medication.dosage_instructions = medication_data[:dosage_instructions]
    medication.authored_on = medication_data[:authored_on]
    medication.authored_by = medication_data[:authored_by]
    medication.save
  end

  include VectorDbService
  def vector_metadata
    {
      medication_id: self.id,
      user_id: self.user_id,
      name: self.name || "",
      status: self.status || "",
      is_archived: self.is_archived,
      authored_on: self.authored_on.nil? ? 0 : self.authored_on.to_i,
      authored_by: self.authored_by || "",
      dosage_instructions: self.dosage_instructions || "",
      source: self.clinical_record.source_name || ""
    }
  end

  def vector_database_upsert
    save_in_vector_db("medications", self.id, self.name, vector_metadata)
  end

  def remove_from_vector_database
    delete_from_vector_db("medications", self.id)
  end

  def self.vector_database_batch_upsert
    vectors = []
    self.find_each(batch_size: 100) do |medication|
      vectors << {
        id: medication.id,
        metadata: medication.vector_metadata,
        values: VectorDbService.get_embedding(medication.name)
      }
      
      if vectors.size >= 100
        batch_upsert_in_vector_db("medications", vectors)
        vectors.clear
      end
    end

    batch_upsert_in_vector_db("medications", vectors) unless vectors.empty?
  end

  def self.search_embeddings(user_id, query, offset = 0, active_only = true, filter = {}, k = 10)
    if query.present? && query != ''
      if filter.present?
        if filter[:start_date].present? || filter[:end_date].present?
          # Get the start of the day for the start_date and the end of the day for the end_date
          start_date = filter[:start_date].present? ? filter[:start_date].to_time.beginning_of_day.to_i : 0
          end_date = filter[:end_date].present? ? filter[:end_date].to_time.end_of_day.to_i : Time.now.to_i

          filter = {
            "$and": [
              { "authored_on": { "$gte": start_date } },
              { "authored_on": { "$lte": end_date } },
            ]
          }
        end
      else 
        filter = {}
      end

      if active_only
        filter.merge!({ "is_archived": false })
      end

      results = query_vector_db("medications", user_id, query, offset, filter, k)
      return results.map do |result|
        {
          score: result[:score],
          data: {
            id: result.dig(:data, :lab_result_id),
            name: result.dig(:data, :name),
            status: result.dig(:data, :status),
            is_archived: result.dig(:data, :is_archived),
            authored_on: result.dig(:data, :authored_on).present? ? Time.at(result.dig(:data, :authored_on)).to_date : nil,
            authored_by: result.dig(:data, :authored_by),
            dosage_instructions: result.dig(:data, :dosage_instructions),
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

          results = self.where(user_id: user_id).where("authored_on >= ? AND authored_on <= ?", start_date, end_date)
        else
          results = self.where(user_id: user_id)
        end
      else
        results = self.where(user_id: user_id)
      end

      if active_only
        results = results.active
      end

      results = results.order(authored_on: :desc).page(page).per(k)

      return {
        results: results.map do |result|
          {
            name: result.name,
            status: result.status,
            is_archived: result.is_archived,
            authored_on: result.authored_on.to_date,
            authored_by: result.authored_by,
            dosage_instructions: result.dosage_instructions
          }
        end,
        total_results: results.total_count,
      }
    end
  end

  private

  def update_medication_summary
    GenerateMedicationSummaryJob.perform_later(self.user_id)
  end
end
