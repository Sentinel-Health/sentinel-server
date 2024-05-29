require_dependency 'open_ai_error'

module VectorDbService
  extend ActiveSupport::Concern

  MODEL = "text-embedding-3-small" 
  EMBEDDING_DIMENSION = 1536
  INDEX_NAME = "sentinel-#{Rails.env}"

  def self.create_index
    index_response = $pinecone.describe_index(INDEX_NAME)
    # Create index if it doesn't already exist
    if index_response.dig('status') == 404
      $pinecone.create_index({
        "metric": "cosine",
        "name": INDEX_NAME,
        "dimension": EMBEDDING_DIMENSION,
        "spec": {
          "serverless": {
            "cloud": Rails.application.credentials.dig(:pinecone, :cloud),
            "region": Rails.application.credentials.dig(:pinecone, :region),
          }
        }
      })
    end
  end

  def self.get_embedding(text)
    response = $openai.embeddings(
      parameters: {
        model: MODEL,
        input: text
      }
    )
  
    response.dig("data", 0, "embedding")
  end

  included do
    def save_in_vector_db(namespace, id, text, metadata)
      embedding = VectorDbService.get_embedding(text)
      index = $pinecone.index(INDEX_NAME)
      upsert_response = index.upsert(
        namespace: namespace,
        vectors: [{
          id: id,
          metadata: metadata,
          values: embedding
        }]
      )

      upsert_response
    end

    def delete_from_vector_db(namespace, id)
      index = $pinecone.index(INDEX_NAME)
      index.delete(
        namespace: namespace,
        ids: [id]
      )
    end
  end

  class_methods do
    def batch_upsert_in_vector_db(namespace, vectors)
      index = $pinecone.index(INDEX_NAME)
      Rails.logger.info "Upserting #{vectors.size} vectors into #{namespace}..."
      upsert_response = index.upsert(
        namespace: namespace,
        vectors: vectors
      )
      Rails.logger.info "upserted response:"
      pp upsert_response
      Rails.logger.info "upserted #{upsert_response.dig("upsertedCount")} vectors"
      Rails.logger.info "Done."
      upsert_response
    end

    def query_vector_db(namespace, user_id, query, offset = 0, filter = {}, k = 10)
      return [] unless user_id.present?
      filters = { "user_id": user_id } # IMPORTANT!
      filters.merge!(filter) if filter.present?

      embedding = VectorDbService.get_embedding(query)
      index = $pinecone.index(INDEX_NAME)
      query_response = index.query(
        vector: embedding, 
        namespace: namespace,
        filter: filters,
        top_k: k,
        include_values: false,
        include_metadata: true
      )

      return [] if query_response.blank?

      return query_response.dig('matches').map do |match|
        {
          score: match.dig('score'),
          data: match.dig('metadata').deep_symbolize_keys,
        }
      end
    end
  end

end
