class Allergy < ApplicationRecord
  belongs_to :user
  belongs_to :clinical_record

  after_create :vector_database_upsert
  after_update :vector_database_upsert, :update_allergy_summary
  after_destroy :remove_from_vector_database

  scope :active, -> { where(status: ['active', 'confirmed'], is_archived: false) }

  def source
    clinical_record.source_name
  end

  include FhirData
  def self.create_from_clinical_record(user_id, clinical_record)
    allergy_data = get_allergy_data_from_fhir_data(clinical_record.fhir_data, clinical_record.fhir_release)
    return unless allergy_data.present?

    allergy = self.find_or_initialize_by(user_id: user_id, clinical_record_id: clinical_record.id)
    allergy.name = allergy_data[:name]
    allergy.status = allergy_data[:status].present? ? allergy_data[:status].downcase : nil
    allergy.recorded_on = allergy_data[:recorded_date]
    allergy.save
  end

  include VectorDbService
  def vector_metadata
    {
      allergy_id: self.id,
      user_id: self.user_id,
      name: self.name || "",
      is_archived: self.is_archived,
      status: self.status || "",
      recorded_on: self.recorded_on.nil? ? 0 : self.recorded_on.to_i,
      source: self.clinical_record.source_name || ""
    }
  end

  def vector_database_upsert
    save_in_vector_db("allergies", id, self.name, vector_metadata)
  end

  def remove_from_vector_database
    delete_from_vector_db("allergies", self.id)
  end

  def self.vector_database_batch_upsert
    vectors = []
    self.find_each(batch_size: 100) do |allergy|
      vectors << {
        id: allergy.id,
        metadata: allergy.vector_metadata,
        values: VectorDbService.get_embedding(allergy.name)
      }

      if vectors.size >= 100
        batch_upsert_in_vector_db("allergies", vectors)
        vectors.clear
      end
    end

    batch_upsert_in_vector_db("allergies", vectors) unless vectors.empty?
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
              { "recorded_on": { "$gte": start_date } },
              { "recorded_on": { "$lte": end_date } },
            ]
          }
        end
      else 
        filter = {}
      end

      if active_only
        filter.merge!({ "is_archived": false })
      end

      results = query_vector_db("allergies", user_id, query, offset, filter, k)
      return results.map do |result|
        {
          score: result[:score],
          data: {
            id: result.dig(:data, :allergy_id),
            name: result.dig(:data, :name),
            status: result.dig(:data, :status),
            is_archived: result.dig(:data, :is_archived),
            recorded_on: result.dig(:data, :recorded_on).present? ? Time.at(result.dig(:data, :recorded_on)).to_date : nil,
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

          results = self.where(user_id: user_id).where("recorded_on >= ? AND recorded_on <= ?", start_date, end_date)
        else
          results = self.where(user_id: user_id)
        end
      else
        results = self.where(user_id: user_id)
      end

      if active_only
        results = results.active
      end

      results = results.order(recorded_on: :desc).page(page).per(k)

      return {
        results: results.map do |result|
          {
            name: result.name,
            status: result.status,
            is_archived: result.is_archived,
            recorded_on: result.recorded_on.to_date,
          }
        end,
        total_results: results.total_count,
      }
    end
  end

  private

  def update_allergy_summary
    GenerateAllergySummaryJob.perform_later(self.user_id)
  end
end
