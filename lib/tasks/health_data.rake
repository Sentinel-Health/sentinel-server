namespace :health_data do
  desc "Remove duplicate records"
  task remove_duplicate_records: :environment do
    Rails.logger.info "Removing duplicate records..."
    ClinicalRecord.transaction do
      duplicate_identifiers = ClinicalRecord
                                .having('COUNT(*) > 1')
                                .group(:identifier)
                                .pluck(:identifier)
    
      duplicate_identifiers.each do |identifier|
        ClinicalRecord.where(identifier: identifier)
                      .order(created_at: :desc)
                      .offset(1)               
                      .destroy_all
      end
    end
    
    Rails.logger.info "Finished removing duplicate records."
  end

  desc "Resynchronizes lab results data for all users"
  task resync_lab_results_data: :environment do
    Rails.logger.info "Resynchronizing lab results data..."
    ClinicalRecord.where(record_type: "Lab Result").find_each(batch_size: 1000) do |clinical_record|
      LabResult.create_from_clinical_record(clinical_record.user_id, clinical_record)
    end
    Rails.logger.info "Finished resynchronizing lab results data."
  end

  desc "Resynchronizes medication data for all users"
  task resync_medication_data: :environment do
    ClinicalRecord.where(record_type: "Medication").find_each(batch_size: 1000) do |clinical_record|
      Medication.create_from_clinical_record(clinical_record.user_id, clinical_record)
    end
  end

  desc "Resynchronizes condition data for all users"
  task resync_condition_data: :environment do
      ClinicalRecord.where(record_type: "Condition").find_each(batch_size: 1000) do |clinical_record|
        Condition.create_from_clinical_record(clinical_record.user_id, clinical_record)
      end
  end

  desc "Resynchronizes immunization data for all users"
  task resync_immunization_data: :environment do
    ClinicalRecord.where(record_type: "Immunization").find_each(batch_size: 1000) do |clinical_record|
      Immunization.create_from_clinical_record(clinical_record.user_id, clinical_record)
    end
  end

  desc "Resynchronizes allergy data for all users"
  task resync_allergy_data: :environment do
    ClinicalRecord.where(record_type: "Allergy").find_each(batch_size: 1000) do |clinical_record|
      Allergy.create_from_clinical_record(clinical_record.user_id, clinical_record)
    end
  end

  desc "Resynchronizes procedure data for all users"
  task resync_procedure_data: :environment do
    ClinicalRecord.where(record_type: "Procedure").find_each(batch_size: 1000) do |clinical_record|
      Procedure.create_from_clinical_record(clinical_record.user_id, clinical_record)
    end
  end
end
