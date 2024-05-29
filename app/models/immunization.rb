class Immunization < ApplicationRecord
  belongs_to :user
  belongs_to :clinical_record

  after_create :vector_database_upsert
  after_update :vector_database_upsert, :update_immunization_summary
  after_destroy :remove_from_vector_database

  scope :active, -> { where(is_archived: false) }

  def source
    clinical_record.source_name
  end

  include FhirData
  def self.create_from_clinical_record(user_id, clinical_record)
    immunization_data = get_immunization_data_from_fhir_data(clinical_record.fhir_data, clinical_record.fhir_release)
    return unless immunization_data.present?

    immunization = self.find_or_initialize_by(user_id: user_id, clinical_record_id: clinical_record.id)
    immunization.name = immunization_data[:name]
    immunization.received_on = immunization_data[:received_date]
    immunization.save
  end

  include VectorDbService
  def vector_metadata
    {
      immunization_id: self.id,
      user_id: self.user_id,
      name: self.name || "",
      is_archived: self.is_archived,
      received_on: self.received_on.nil? ? 0 : self.received_on.to_time.to_i,
      source: self.clinical_record.source_name || ""
    }
  end

  def vector_database_upsert
    save_in_vector_db("immunizations", id, self.name, vector_metadata)
  end

  def remove_from_vector_database
    delete_from_vector_db("immunizations", self.id)
  end

  def self.vector_database_batch_upsert
    vectors = []
    self.find_each(batch_size: 100) do |immunization|
      vectors << {
        id: immunization.id,
        metadata: immunization.vector_metadata,
        values: VectorDbService.get_embedding(immunization.name)
      }

      if vectors.size >= 100
        batch_upsert_in_vector_db("immunizations", vectors)
        vectors.clear
      end
    end

    batch_upsert_in_vector_db("immunizations", vectors) unless vectors.empty?
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
              { "received_on": { "$gte": start_date } },
              { "received_on": { "$lte": end_date } },
            ]
          }
        end
      else 
        filter = {}
      end

      if active_only
        filter.merge!({ "is_archived": false })
      end

      results = query_vector_db("immunizations", user_id, query, offset, filter, k)
      return results.map do |result|
        {
          score: result[:score],
          data: {
            id: result.dig(:data, :immunization_id),
            name: result.dig(:data, :name),
            is_archived: result.dig(:data, :is_archived),
            received_on: result.dig(:data, :received_on).present? ? Time.at(result.dig(:data, :received_on)).to_date : nil,
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

          results = self.where(user_id: user_id).where("received_on >= ? AND received_on <= ?", start_date, end_date)
        else
          results = self.where(user_id: user_id)
        end
      else
        results = self.where(user_id: user_id)
      end

      if active_only
        results = results.active
      end

      results = results.order(received_on: :desc).page(page).per(k)

      return {
        results: results.map do |result|
          {
            name: result.name,
            is_archived: result.is_archived,
            received_on: result.received_on.to_date,
          }
        end,
        total_results: results.total_count,
      }
    end
  end

  private

  def update_immunization_summary
    GenerateImmunizationSummaryJob.perform_later(self.user_id)
  end
end
