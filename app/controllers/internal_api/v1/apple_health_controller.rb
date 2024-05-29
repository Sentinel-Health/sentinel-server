class InternalApi::V1::AppleHealthController < InternalApi::V1::BaseController
  include AppleHealth

  def sync_quantity_samples
    samples = params[:samples]
    quantity_samples_data = samples.map do |sample|
      {
        user_id: @current_user.id,
        identifier: sample[:uuid],
        source_name: sample.dig('sourceRevision', 'source', 'name'),
        source_version: sample.dig('sourceRevision', 'version'),
        device: sample.dig('device', 'name'),
        sample_type: map_apple_health_quantity_type(sample[:quantityType]),
        unit: sample[:unit],
        start_date: DateTime.parse(sample[:startDate]),
        end_date: DateTime.parse(sample[:endDate]),
        value: sample[:quantity],
        metadata: sample[:metadata],
        updated_at: DateTime.current,
        created_at: DateTime.current
      }
    end

    HealthQuantitySample.upsert_all(quantity_samples_data, unique_by: %i[user_id identifier])
    render json: { success: true }
  end

  def remove_quantity_samples
    identifiers = params[:identifiers]
  
    # This was causing issues with missing data, so we're not deleting data for now
    # Retriable.retriable(on: ActiveRecord::Deadlocked, tries: 3, base_interval: 0.5) do
    #   HealthQuantitySample.where(identifier: identifiers).delete_all
    # end
  
    render json: { success: true }
  rescue ActiveRecord::Deadlocked
    render json: { success: false, error: "An error occurred while processing your request. Please try again." }, status: :internal_server_error
  end

  def sync_quantity_summaries
    summaries = params[:summaries]
    quantity_summaries_data = summaries.map do |summary|
      {
        user_id: @current_user.id,
        data_type: map_apple_health_quantity_type(summary[:quantityType]),
        summary_type: summary[:summaryType],
        unit: summary[:unit],
        value: summary[:quantity],
        date: summary[:date],
        updated_at: DateTime.current,
        created_at: DateTime.current
      }
    end

    HealthQuantitySummary.upsert_all(quantity_summaries_data, unique_by: %i[user_id data_type summary_type date])
    render json: { success: true }
  end

  def sync_category_samples
    samples = params[:samples]
    category_samples_data = samples.map do |sample|
      {
        user_id: @current_user.id,
        identifier: sample[:uuid],
        source_name: sample.dig('sourceRevision', 'source', 'name'),
        source_version: sample.dig('sourceRevision', 'version'),
        device: sample.dig('device', 'name'),
        sample_type: map_apple_health_category_type(sample[:categoryType]),
        start_date: DateTime.parse(sample[:startDate]),
        end_date: DateTime.parse(sample[:endDate]),
        value: map_apple_health_category_value(sample[:categoryType], sample[:value]),
        metadata: sample[:metadata],
        updated_at: DateTime.current,
        created_at: DateTime.current
      }
    end

    HealthCategorySample.upsert_all(category_samples_data, unique_by: %i[user_id identifier])
    render json: { success: true }
  end

  def remove_category_samples
    identifiers = params[:identifiers]

    # This was causing issues with missing data, so we're not deleting data for now
    # Retriable.retriable(on: ActiveRecord::Deadlocked, tries: 3, base_interval: 0.5) do
    #   HealthCategorySample.where(identifier: identifiers).delete_all
    # end
  
    render json: { success: true }
  rescue ActiveRecord::Deadlocked
    render json: { success: false, error: "An error occurred while processing your request. Please try again." }, status: :internal_server_error
  end

  def sync_health_profile
    profile = params[:profile]

    health_profile = HealthProfile.find_or_initialize_by(user_id: @current_user.id)
    health_profile.legal_first_name = @current_user.first_name unless health_profile.legal_first_name.present?
    health_profile.legal_last_name = @current_user.last_name unless health_profile.legal_last_name.present?
    health_profile.wheelchair_use = profile[:wheelchairUse] unless health_profile.wheelchair_use.present?
    health_profile.sex = profile[:biologicalSex] unless health_profile.sex.present?
    health_profile.blood_type = profile[:bloodType] unless health_profile.blood_type.present?
    health_profile.dob = profile[:dateOfBirth] unless health_profile.dob.present?
    health_profile.skin_type = profile[:skinType] unless health_profile.skin_type.present?
    health_profile.save

    render json: { success: true }
  end

  def sync_clinical_records
    records = params[:records]

    new_lab_result_ids = []
    new_allergy_record_ids = []
    new_medication_record_ids = []
    new_condition_record_ids = []
    new_immunization_record_ids = []
    new_procedure_record_ids = []

    # TODO: Refactor this to use a bulk insert, batching, and/or a background job
    records.each do |record|
      clinical_type = map_apple_health_clinical_type(record[:clinicalType]);

      clinical_record = ClinicalRecord.find_or_initialize_by(user_id: @current_user.id, identifier: record[:uuid])
      clinical_record.record_type = clinical_type
      clinical_record.source_name = record.dig('sourceRevision', 'source', 'name')
      clinical_record.source_version = record.dig('sourceRevision', 'version')
      clinical_record.fhir_release = record[:fhirRelease]
      clinical_record.fhir_version = record[:fhirVersion]
      clinical_record.fhir_data = record[:fhirData]
      clinical_record.received_date = DateTime.parse(record[:startDate])

      is_new_record = clinical_record.new_record?
      clinical_record.save

      case clinical_type
      when "Allergy"
        Allergy.create_from_clinical_record(@current_user.id, clinical_record)
        new_allergy_record_ids << clinical_record.id if is_new_record
      when "Medication"
        Medication.create_from_clinical_record(@current_user.id, clinical_record)
        new_medication_record_ids << clinical_record.id if is_new_record
      when "Condition"
        Condition.create_from_clinical_record(@current_user.id, clinical_record)
        new_condition_record_ids << clinical_record.id if is_new_record
      when "Immunization"
        Immunization.create_from_clinical_record(@current_user.id, clinical_record)
        new_immunization_record_ids << clinical_record.id if is_new_record
      when "Procedure"
        Procedure.create_from_clinical_record(@current_user.id, clinical_record)
        new_procedure_record_ids << clinical_record.id if is_new_record
      when "Lab Result"
        lab_result = LabResult.create_from_clinical_record(@current_user.id, clinical_record)
        new_lab_result_ids << lab_result.id if is_new_record
      end
    end

    if new_lab_result_ids.any?
      Rails.logger.info("#{new_lab_result_ids.count} new lab results from Apple Health")
      GenerateLabResultsSummaryJob.perform_later(@current_user.id)
      NewLabResultsNotificationJob.perform_later(@current_user.id, new_lab_result_ids)
    end
    if new_allergy_record_ids.any?
      GenerateAllergySummaryJob.perform_later(@current_user.id)
    end
    if new_medication_record_ids.any?
      GenerateMedicationSummaryJob.perform_later(@current_user.id)
    end
    if new_condition_record_ids.any?
      GenerateConditionSummaryJob.perform_later(@current_user.id)
    end
    if new_immunization_record_ids.any?
      GenerateImmunizationSummaryJob.perform_later(@current_user.id)
    end
    if new_procedure_record_ids.any?
      GenerateProceduresSummaryJob.perform_later(@current_user.id)
    end

    render json: { success: true }
  end

  def remove_clinical_records
    identifiers = params[:identifiers]

    # This was causing issues with missing data, so we're not deleting records for now
    # Retriable.retriable(on: ActiveRecord::Deadlocked, tries: 3, base_interval: 0.5) do
    #   ClinicalRecord.where(identifier: identifiers).destroy_all
    # end
  
    render json: { success: true }
  rescue ActiveRecord::Deadlocked
    render json: { success: false, error: "An error occurred while processing your request. Please try again." }, status: :internal_server_error
  end

  def sync_workout_data
    workouts = params[:workouts]
    workouts_sample_data = workouts.map do |workout|
      {
        user_id: @current_user.id,
        identifier: workout[:uuid],
        source_name: workout.dig('sourceRevision', 'source', 'name'),
        source_version: workout.dig('sourceRevision', 'version'),
        device: workout.dig('device', 'name'),
        activity_type: map_apple_health_workout_activity_type(workout[:workoutActivityType]),
        duration: workout[:duration],
        duration_unit: workout[:durationUnit],
        total_distance: workout.dig('totalDistance', 'quantity'),
        total_distance_unit: workout.dig('totalDistance', 'unit'),
        total_energy_burned: workout.dig('totalEnergyBurned', 'quantity'),
        total_energy_burned_unit: workout.dig('totalEnergyBurned', 'unit'),
        start_date: DateTime.parse(workout[:startDate]),
        end_date: DateTime.parse(workout[:endDate]),
        metadata: workout[:metadata],
        updated_at: DateTime.current,
        created_at: DateTime.current
      }
    end

    Workout.upsert_all(workouts_sample_data, unique_by: %i[user_id identifier])
    render json: { success: true }
  end

  def remove_workout_data
    identifiers = params[:identifiers]

    # This was causing issues with missing data, so we're not deleting data for now
    # Retriable.retriable(on: ActiveRecord::Deadlocked, tries: 3, base_interval: 0.5) do
    #   Workout.where(identifier: identifiers).delete_all
    # end
  
    render json: { success: true }
  rescue ActiveRecord::Deadlocked
    render json: { success: false, error: "An error occurred while processing your request. Please try again." }, status: :internal_server_error
  end
end