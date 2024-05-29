namespace :vector_db do
  desc "Create the vector database index"
  task create_index: :environment do
    Rails.logger.info "Creating vector database index..."
    VectorDbService.create_index
    Rails.logger.info "Done. Created index '#{VectorDbService::INDEX_NAME}' with dimension #{VectorDbService::EMBEDDING_DIMENSION}."
  end

  desc "Reindexes all vector data"
  task reindex_all: :environment do
    Rake::Task["vector_db:reindex_lab_results"].invoke
    Rake::Task["vector_db:reindex_messages"].invoke
    Rake::Task["vector_db:reindex_conditions"].invoke
    Rake::Task["vector_db:reindex_medications"].invoke
    Rake::Task["vector_db:reindex_allergies"].invoke
    Rake::Task["vector_db:reindex_procedures"].invoke
    Rake::Task["vector_db:reindex_immunizations"].invoke
  end

  desc "Reindexes all lab results"
  task reindex_lab_results: :environment do
    Rails.logger.info "Reindexing lab results..."
    LabResult.vector_database_batch_upsert
    Rails.logger.info "Done."
  end

  desc "Reindexes all messages"
  task reindex_messages: :environment do
    Rails.logger.info "Reindexing messages..."
    Message.where(role: ['user', 'assistant']).vector_database_batch_upsert
    Rails.logger.info "Done."
  end

  desc "Reindexes all conditions"
  task reindex_conditions: :environment do
    Rails.logger.info "Reindexing conditions..."
    Condition.vector_database_batch_upsert
    Rails.logger.info "Done."
  end


  desc "Reindexes all medications"
  task reindex_medications: :environment do
    Rails.logger.info "Reindexing medications..."
    Medication.vector_database_batch_upsert
    Rails.logger.info "Done."
  end


  desc "Reindexes all allergies"
  task reindex_allergies: :environment do
    Rails.logger.info "Reindexing allergies..."
    Allergy.vector_database_batch_upsert
    Rails.logger.info "Done."
  end


  desc "Reindexes all procedures"
  task reindex_procedures: :environment do
    Rails.logger.info "Reindexing procedures..."
    Procedure.vector_database_batch_upsert
    Rails.logger.info "Done."
  end

  desc "Reindexes all immunizations"
  task reindex_immunizations: :environment do
    Rails.logger.info "Reindexing immunizations..."
    Immunization.vector_database_batch_upsert
    Rails.logger.info "Done."
  end
end
