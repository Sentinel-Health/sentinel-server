class Procedure < ApplicationRecord
  belongs_to :user
  belongs_to :clinical_record

  after_create :vector_database_upsert
  after_update :vector_database_upsert, :update_procedures_summary
  after_destroy :remove_from_vector_database

  scope :active, -> { where(is_archived: false) }

  def source
    clinical_record.source_name
  end

  include FhirData
  def self.create_from_clinical_record(user_id, clinical_record)
    procedure_data = get_procedure_data_from_fhir_data(clinical_record.fhir_data)
    return unless procedure_data.present?

    procedure = self.find_or_initialize_by(user_id: user_id, clinical_record_id: clinical_record.id)
    procedure.name = procedure_data[:name]
    procedure.status = procedure_data[:status].present? ? procedure_data[:status].downcase : nil
    procedure.performed_on = procedure_data[:performed_date]
    procedure.save
  end

  include VectorDbService
  def vector_metadata
    {
      procedure_id: self.id,
      user_id: self.user_id,
      name: self.name || "",
      status: self.status || "",
      is_archived: self.is_archived,
      performed_on: self.performed_on.nil? ? 0 : self.performed_on.to_time.to_i,
      source: self.clinical_record.source_name || ""
    }
  end

  def vector_database_upsert
    save_in_vector_db("procedures", id, self.name, vector_metadata)
  end

  def remove_from_vector_database
    delete_from_vector_db("procedures", self.id)
  end

  def self.vector_database_batch_upsert
    vectors = []
    self.find_each(batch_size: 100) do |procedure| # fetch records in batches of 100
      vectors << {
        id: procedure.id,
        metadata: procedure.vector_metadata,
        values: VectorDbService.get_embedding(procedure.name)
      }
  
      if vectors.size >= 100
        batch_upsert_in_vector_db("procedures", vectors)
        vectors.clear
      end
    end
  
    batch_upsert_in_vector_db("procedures", vectors) unless vectors.empty?
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
              { "performed_on": { "$gte": start_date } },
              { "performed_on": { "$lte": end_date } },
            ]
          }
        end
      else 
        filter = {}
      end

      if active_only
        filter.merge!({ "is_archived": false })
      end

      results = query_vector_db("procedures", user_id, query, offset, filter, k)
      return results.map do |result|
        {
          score: result[:score],
          data: {
            id: result.dig(:data, :procedure_id),
            name: result.dig(:data, :name),
            status: result.dig(:data, :status),
            is_archived: result.dig(:data, :is_archived),
            performed_on: result.dig(:data, :performed_on).present? ? Time.at(result.dig(:data, :performed_on)).to_date : nil,
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

          results = self.where(user_id: user_id).where("performed_on >= ? AND performed_on <= ?", start_date, end_date)
        else
          results = self.where(user_id: user_id)
        end
      else
        results = self.where(user_id: user_id)
      end

      if active_only
        results = results.active
      end

      results = results.order(performed_on: :desc).page(page).per(k)

      return {
        results: results.map do |result|
          {
            name: result.name,
            status: result.status,
            is_archived: result.is_archived,
            performed_on: result.performed_on.to_date,
          }
        end,
        total_results: results.total_count,
      }
    end
  end

  private

  def update_procedures_summary
    GenerateProceduresSummaryJob.perform_later(self.user_id)
  end
end
