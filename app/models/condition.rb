class Condition < ApplicationRecord
  belongs_to :user
  
  has_many :condition_histories, dependent: :destroy

  after_create :vector_database_upsert
  after_update :vector_database_upsert, :update_condition_summary
  after_destroy :remove_from_vector_database

  scope :active, -> { where(status: 'active', is_archived: false) }

  def most_recent_history
    condition_histories.order(created_at: :desc).first
  end

  def most_recent_source
    most_recent_history.try(:source)
  end

  include FhirData
  def self.create_from_clinical_record(user_id, clinical_record)
    condition_data = get_condition_data_from_fhir_data(clinical_record.fhir_data, clinical_record.fhir_release)
    return unless condition_data.present?

    condition = self.find_or_initialize_by(user_id: user_id, name: condition_data[:name])

    most_recent_history = find_most_recent_history(condition.name)

    if most_recent_history.present? && most_recent_history.recorded_on < condition_data[:recorded_date]
      condition_status = most_recent_history.status
    elsif condition_data[:clinical_status].present?
      condition_status = condition_data[:clinical_status].downcase
    end

    condition.status = condition_status
    condition.save
    
    condition_history = ConditionHistory.find_or_initialize_by(name: condition_data[:name], clinical_record_id: clinical_record.id)
    condition_history.condition = condition
    condition_history.name = condition_data[:name]
    condition_history.status = condition_data[:clinical_status].present? ? condition_data[:clinical_status].downcase : nil
    condition_history.recorded_on = condition_data[:recorded_date]
    condition_history.recorded_by = condition_data[:recorded_by]
    condition_history.save
  end

  include VectorDbService
  def vector_metadata
    most_recent_history = self.most_recent_history
    {
      condition_id: self.id,
      user_id: self.user_id,
      name: self.name || "",
      is_archived: self.is_archived,
      status: self.status || "",
      recorded_on: most_recent_history.try(:recorded_on) ? most_recent_history.recorded_on.to_i : 0,
      source: self.most_recent_source || ""
    }
  end

  def vector_database_upsert
    save_in_vector_db("conditions", id, self.name, vector_metadata)
  end

  def remove_from_vector_database
    delete_from_vector_db("conditions", self.id)
  end

  def self.vector_database_batch_upsert
    vectors = []
    self.find_each(batch_size: 100) do |condition|
      vectors << {
        id: condition.id,
        metadata: condition.vector_metadata,
        values: VectorDbService.get_embedding(condition.name)
      }

      if vectors.size >= 100
        batch_upsert_in_vector_db("conditions", vectors)
        vectors.clear
      end
    end

    batch_upsert_in_vector_db("conditions", vectors) unless vectors.empty?
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

      results = query_vector_db("conditions", user_id, query, offset, filter, k)
      return results.map do |result|
        {
          score: result[:score],
          data: {
            id: result.dig(:data, :condition_id),
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

          results = Condition.includes(:condition_histories).where(user_id: user_id).where("condition_histories.recorded_on >= ? AND condition_histories.recorded_on <= ?", start_date, end_date)
        else
          results = Condition.includes(:condition_histories).where(user_id: user_id)
        end
      else
        results = Condition.includes(:condition_histories).where(user_id: user_id)
      end

      if active_only
        results = results.active
      end

      results = results.order('condition_histories.recorded_on desc').page(page).per(k)

      return {
        results: results.map do |result|
          {
            name: result.name,
            status: result.status,
            is_archived: result.is_archived,
            recorded_on: result.most_recent_history.recorded_on.to_date,
          }
        end,
        total_results: results.total_count,
      }
    end
  end

  private

  def self.find_most_recent_history(condition_name)
    ConditionHistory.where(name: condition_name).order(recorded_on: :desc).first
  end

  def update_condition_summary
    GenerateConditionSummaryJob.perform_later(self.user_id)
  end
end
