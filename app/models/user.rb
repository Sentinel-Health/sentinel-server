require 'open-uri'
require 'mime/types'

class User < ApplicationRecord
  has_one :health_profile, dependent: :destroy
  has_one :notification_setting, dependent: :destroy
  has_one_attached :profile_picture

  has_many :sessions, dependent: :destroy
  has_many :health_quantity_samples, dependent: :destroy
  has_many :health_quantity_summaries, dependent: :destroy
  has_many :health_category_samples, dependent: :destroy
  has_many :workouts, dependent: :destroy
  has_many :clinical_records, dependent: :destroy
  has_many :conversations, dependent: :destroy
  has_many :messages, through: :conversations
  has_many :health_summaries, dependent: :destroy
  has_many :lab_results, dependent: :destroy
  has_many :conditions, dependent: :destroy
  has_many :medications, dependent: :destroy
  has_many :allergies, dependent: :destroy
  has_many :immunizations, dependent: :destroy
  has_many :procedures, dependent: :destroy
  has_many :health_insights, dependent: :destroy
  has_many :devices, dependent: :destroy
  has_many :notifications, class_name: 'UserNotification', dependent: :destroy
  has_many :chat_suggestions, dependent: :destroy
  has_many :chat_feedback, dependent: :destroy
  has_many :session_audit_trails, dependent: :destroy
  has_many :lab_test_orders, dependent: :destroy
  has_many :user_consents, dependent: :destroy

  validates :email, uniqueness: true
  validates :phone_number, phone: { 
    possible: true, 
    allow_blank: true, 
    types: [:voip, :mobile], 
    country_specifier: -> phone { phone.country.try(:upcase) } 
  }

  enum :role, { member: "member", admin: "admin" }, validate: true

  encrypts :first_name
  encrypts :last_name
  encrypts :email, deterministic: true, downcase: true
  encrypts :phone_number, deterministic: true
  encrypts :picture
  encrypts :address_line_1
  encrypts :address_line_2
  encrypts :city
  encrypts :state
  encrypts :zip_code
  encrypts :country

  after_create :create_notification_settings, :create_health_profile, :create_stripe_customer
  after_update :update_stripe_customer, if: -> { saved_change_to_email? || saved_change_to_first_name? || saved_change_to_last_name? || saved_change_to_phone_number? || saved_change_to_phone_number_verified? || saved_change_to_email_verified? || saved_change_to_address_line_1? || saved_change_to_address_line_2? || saved_change_to_city? || saved_change_to_state? || saved_change_to_zip_code? || saved_change_to_country? }
  after_save :update_profile_picture, if: -> { saved_change_to_picture? }

  include FhirData
  include SummaryService
  include HealthInsightsService
  include ChatSuggestionsService
  include ChatService

  def calculate_age(dob)
    return nil if dob.nil?

    dob = Date.parse(dob)

    now = Time.now.utc.to_date
    now.year - dob.year - (dob.to_date.change(year: now.year) > now ? 1 : 0)
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def address_string
    parts = []
    parts << address_line_1 unless address_line_1.blank?
    parts << address_line_2 unless address_line_2.blank?
    # Combining city, state, and zip code if they exist
    city_state_zip = [city, state, zip_code].reject(&:blank?).join(", ")
    parts << city_state_zip unless city_state_zip.blank?
    parts << country unless country.blank?
    
    # Formatting based on available parts
    if parts.empty?
      return nil
    else
      parts.join(", ")
    end
  end

  def create_new_session(request, browser)
    access_token, payload = Session.create_access_token(self.id)
    refresh_token = Session.create_refresh_token(self.id)
    session = Session.create!(
      user: self,
      access_token: access_token,
      refresh_token: refresh_token,
      exp: payload[:exp],
      iat: payload[:iat],
      ip_address: request.remote_ip,
      device: browser.device.name,
      platform: browser.platform.name,
    )
    session
  end

  def current_date
    Time.current.in_time_zone(self.timezone).to_date
  end

  def is_eligible_for_lab_tests?
    # Checks if user is eligible for lab tests, if not, return reason
    requirements = []
    if self.health_profile.legal_first_name.blank? || 
      self.health_profile.legal_last_name.blank? || 
      self.health_profile.dob.blank? || 
      self.health_profile.sex.blank?
      requirements << :health_profile
    end
    if self.address_line_1.blank? || self.city.blank? || self.state.blank? || self.zip_code.blank?
      requirements << :address
    end
    if self.phone_number.blank? || !self.phone_number_verified
      requirements << :phone_number
    end
    if !self.has_consent_for?(:hipaa_authorization)
      requirements << :hipaa_authorization
    end
    if !self.has_consent_for?(:telehealth_consent)
      requirements << :telehealth_consent
    end
    return false, requirements unless requirements.empty?

    return true, nil
  end

  def number_of_lab_test_orders
    Rails.cache.fetch("lab_test_orders/count/v1.0/#{self.cache_key_with_version}") do
      self.lab_test_orders.count
    end
  end

  def generate_health_summaries
    generate_allergy_summary
    generate_medication_summary
    generate_condition_summary
    generate_immunization_summary
    generate_procedures_summary
    generate_lab_results_summary
  end

  def generate_allergy_summary
    allergy_data = self.allergies.active.map do |allergy|
      {
        name: allergy.name,
        status: allergy.status,
        recorded_on: allergy.recorded_on,
      }
    end

    prompt = "Please summarize this user's allergy data: #{allergy_data.to_json}"
    summary, model_used = get_summary(prompt)

    return if summary.blank?

    health_summary = self.health_summaries.find_or_initialize_by(category: HealthSummary.categories[:allergies])
    health_summary.summary = summary
    health_summary.model_used = model_used
    health_summary.save
  end

  def generate_medication_summary
    medication_data = self.medications.active.map do |medication|
      {
        name: medication.name,
        status: medication.status,
        authored_on: medication.authored_on,
        dosage_instructions: medication.dosage_instructions,
        authored_by: medication.authored_by
      }
    end

    prompt = "Please summarize this user's medication data: #{medication_data.to_json}"
    summary, model_used = get_summary(prompt)

    return if summary.blank?

    health_summary = self.health_summaries.find_or_initialize_by(category: HealthSummary.categories[:medications])
    health_summary.summary = summary
    health_summary.model_used = model_used
    health_summary.save
  end

  def generate_condition_summary
    condition_data = self.conditions.active.map do |condition|
      {
        name: condition.name,
        status: condition.status,
        history: condition.condition_histories.map do |history|
          {
            recorded_on: history.recorded_on,
            recorded_by: history.recorded_by,
            status: history.status,
          }
        end
      }
    end

    prompt = "Please summarize this user's condition data: #{condition_data.to_json}"
    summary, model_used = get_summary(prompt)

    return if summary.blank?

    health_summary = self.health_summaries.find_or_initialize_by(category: HealthSummary.categories[:conditions])
    health_summary.summary = summary
    health_summary.model_used = model_used
    health_summary.save
  end

  def generate_immunization_summary
    immunization_data = self.immunizations.active.map do |allergy|
      {
        name: allergy.name,
        received_on: allergy.received_on,
      }
    end

    prompt = "Please summarize this user's immunization data: #{immunization_data.to_json}"
    summary, model_used = get_summary(prompt)

    return if summary.blank?

    health_summary = self.health_summaries.find_or_initialize_by(category: HealthSummary.categories[:immunizations])
    health_summary.summary = summary
    health_summary.model_used = model_used
    health_summary.save
  end

  def generate_procedures_summary
    procedure_data = self.procedures.active.map do |procedure|
      {
        name: procedure.name,
        status: procedure.status,
        performed_on: procedure.performed_on,
      }
    end

    prompt = "Please summarize this user's procedure data: #{procedure_data.to_json}"
    summary, model_used = get_summary(prompt)

    return if summary.blank?

    health_summary = self.health_summaries.find_or_initialize_by(category: HealthSummary.categories[:procedures])
    health_summary.summary = summary
    health_summary.model_used = model_used
    health_summary.save
  end

  def generate_lab_results_summary
    lab_results_data = self.clinical_records.where(record_type: "Lab Result").pluck(:fhir_data)

    most_recent_date = lab_results_data.map { |data| data['issued'] }.compact.max
    recent_lab_results_data = lab_results_data.select { |data| data['issued'] == most_recent_date }
    lab_result_data = recent_lab_results_data.compact.map do |fhir_data|
      User.get_lab_result_data_from_fhir_data(fhir_data)
    end

    refined_lab_result_data = lab_result_data.compact.map do |lab_result|
      {
        name: lab_result[:name],
        issued: lab_result[:issued],
        value: lab_result[:value_string],
        reference_range: lab_result[:reference_range_string],
      }
    end

    prompt = "Please summarize this user's most recent lab results data: #{refined_lab_result_data.to_json}"
    summary, model_used = get_summary(prompt)

    return if summary.blank?

    health_summary = self.health_summaries.find_or_initialize_by(category: HealthSummary.categories[:lab_results])
    health_summary.summary = summary
    health_summary.model_used = model_used
    health_summary.save
  end

  def health_goals_text
    return unless self.health_goals.present?

    text = "## Health Goals\n"
    text += "- Be healthy generally\n" if self.health_goals['general_health'].present?
    text += "- Live longer\n" if self.health_goals['live_longer'].present?
    text += "- Manage an existing condition(s)\n" if self.health_goals['manage_condition'].present?
    text += "- Better navigate the healthcare system\n" if self.health_goals['navigate_system'].present?
    text += "- Getting answers to health questions\n" if self.health_goals['answer_health_questions'].present?
    text += "- Manage my weight" if self.health_goals['manage_weight'].present?
    text += "- Slow aging" if self.health_goals['slow_aging'].present?
    text += "- Optimize athletic performance" if self.health_goals['optimize_athletic_performance'].present?
    text += "- #{self.health_goals['other_text']}" if self.health_goals['other'].present?
    return text
  end

  def health_data_summary
    health_profile = self.health_profile
    height = self.get_most_recent_quantity_sample("Height")
    weight = self.get_most_recent_quantity_sample("Body Mass")
    health_summaries = self.health_summaries

    summary_text = "## User Information\n"
    summary_text += "First name: #{self.first_name}\n" if self.first_name.present?
    summary_text += "Age: #{calculate_age(health_profile.dob)}\n" if health_profile.dob.present?
    summary_text += "Sex: #{health_profile.sex}\n" if health_profile.sex.present?
    summary_text += "Blood Type: #{health_profile.blood_type}\n" if health_profile.blood_type.present?
    summary_text += "Skin Type: #{health_profile.skin_type}\n" if health_profile.skin_type.present?
    summary_text += "Wheelchair use: #{health_profile.wheelchair_use}\n" if health_profile.wheelchair_use.present?
    summary_text += "Height: #{height.value} #{height.unit}\n" if height.present?
    summary_text += "Weight: #{weight.value} #{weight.unit}\n" if weight.present?

    if self.health_goals.present?
      summary_text += self.health_goals_text if self.health_goals_text.present?
    end

    if health_summaries.present?
      summary_text += "\n## Health Summaries\n"
      health_summaries.each do |hs|
        summary_text += "### #{hs.category.try(:capitalize)}\n#{hs.summary}\n\n"
      end
    end

    avg_weight = self.average_weight
    avg_bmi = self.average_bmi
    avg_body_fat = self.average_body_fat
    if avg_weight.present? || avg_bmi.present? || avg_body_fat.present?
      body_data_text = "### Body Data\n"
      body_data_text += "Avg weight (in last month): #{avg_weight.dig(:value)}#{avg_weight.dig(:unit)}\n" if avg_weight.present?
      body_data_text += "Avg BMI (in last month): #{avg_bmi.dig(:value)}\n" if avg_bmi.present?
      body_data_text += "Avg body fat % (in last month): #{avg_body_fat.dig(:value) * 100}#{avg_body_fat.dig(:unit)}\n" if avg_body_fat.present?
    end

    avg_daily_steps = self.average_daily_steps
    avg_weekly_workout_mins = self.average_weekly_workout_mins
    avg_resting_heart_rate = self.average_resting_heart_rate
    most_recent_vo2_max = self.get_most_recent_quantity_sample("VO2 Max")
    avg_respiratory_rate = self.average_respiratory_rate
    if avg_daily_steps.present? || avg_weekly_workout_mins.present? || avg_resting_heart_rate.present? || most_recent_vo2_max.present? || avg_respiratory_rate.present?
      fitness_data_text = "### Fitness Data\n"
      fitness_data_text += "Avg daily steps (in last month): #{avg_daily_steps}\n" if avg_daily_steps.present?
      fitness_data_text += "Avg number of minutes working out per week (in last month): #{avg_weekly_workout_mins}\n" if avg_weekly_workout_mins.present?
      fitness_data_text += "Avg resting heart rate (in last month): #{avg_resting_heart_rate.dig(:value)}\n" if avg_resting_heart_rate.present?
      fitness_data_text += "Most recent Vo2 Max: #{most_recent_vo2_max.try(:value)}\n" if most_recent_vo2_max.present?
      fitness_data_text += "Average Respiratory Rate (in last month): #{avg_respiratory_rate.dig(:value)}\n" if avg_respiratory_rate.present?
    end

    avg_hours_slept = self.average_hours_slept
    if avg_hours_slept.present?
      sleep_data_text = "### Sleep Data\n"
      sleep_data_text += "Avg hrs sleep per night (in last month): #{avg_hours_slept}\n"
    end

    if body_data_text.present? || fitness_data_text.present? || sleep_data_text.present?
      summary_text += "\n## Health Data Summary\n"
      summary_text += "#{body_data_text}\n" if body_data_text.present?
      summary_text += "#{fitness_data_text}\n" if fitness_data_text.present?
      summary_text += "#{sleep_data_text}\n" if sleep_data_text.present?
    end

    return summary_text
  end

  def most_recent_data_summary
    latest_steps = self.health_quantity_summaries.where(data_type: "Step Count").order(date: :desc).limit(1).first
    latest_resting_heart_rate = self.get_most_recent_quantity_sample("Resting Heart Rate")
    latest_vo2_max = self.get_most_recent_quantity_sample("VO2 Max")
    latest_respiratory_rate = self.get_most_recent_quantity_sample("Respiratory Rate")
    current_week_workouts = self.get_cleaned_workouts_over_range(start_date: Time.now.beginning_of_week, end_date: Time.now.end_of_week)
    if current_week_workouts.present?
      current_week_workouts_mins = current_week_workouts.sum(&:duration) / 60.0
    end
    latest_sleep = self.get_most_recent_sleep
    latest_body_fat = self.get_most_recent_quantity_sample("Body Fat Percentage")
    latest_bmi = self.get_most_recent_quantity_sample("Body Mass Index")

    data_summary = ""
    if latest_steps.present?
      data_summary += "Steps: #{latest_steps.value} (on: #{latest_steps.date})\n"
    end
    if latest_resting_heart_rate.present?
      data_summary += "Resting Heart Rate: #{latest_resting_heart_rate.value} (on: #{latest_resting_heart_rate.end_date.to_date})\n"
    end
    if latest_vo2_max.present?
      data_summary += "VO2 Max: #{latest_vo2_max.value} (on: #{latest_vo2_max.end_date.to_date})\n"
    end
    if latest_respiratory_rate.present?
      data_summary += "Respiratory Rate: #{latest_respiratory_rate.value} (on: #{latest_respiratory_rate.end_date.to_date})\n"
    end
    if current_week_workouts_mins.present?
      data_summary += "Workouts mins this week: #{current_week_workouts_mins}\n"
    end
    if latest_sleep.present?
      data_summary += "Sleep: #{latest_sleep.dig(:value)} hrs (on: #{latest_sleep.dig(:date)})\n"
    end
    if latest_body_fat.present?
      data_summary += "Body Fat: #{latest_body_fat.value * 100}% (on: #{latest_body_fat.end_date.to_date})\n"
    end
    if latest_bmi.present?
      data_summary += "BMI: #{latest_bmi.value} (on: #{latest_bmi.end_date.to_date})\n"
    end

    return data_summary
  end

  def biomarkers_summary
    results = self.lab_results
    biomarker_ids = results.select(:biomarker_id).distinct
    biomarkers = Biomarker.where(id: biomarker_ids)
    subcategory_ids = biomarkers.select(:biomarker_subcategory_id).distinct
    subcategories = BiomarkerSubcategory.where(id: subcategory_ids)
    category_ids = subcategories.select(:biomarker_category_id).distinct
    all_biomarker_categories = BiomarkerCategory.where(id: category_ids)

    out_of_range_biomarker_samples = LabResult.all_most_recent_out_of_range_for_user(self.id)
    out_of_range_biomarkers = Biomarker.where(id: out_of_range_biomarker_samples.pluck(:biomarker_id).uniq)
    out_of_range_biomarker_categories = out_of_range_biomarkers.map(&:biomarker_category).uniq

    if all_biomarker_categories.blank?
      return "No biomarkers data"
    end

    biomarkers_summary = "Biomarkers:
#{all_biomarker_categories.map do |category|
  "#{category.name}:
  #{if out_of_range_biomarker_categories.include?(category)
      out_of_range_biomarkers.select { |biomarker| biomarker.biomarker_category == category }.map do |biomarker|
        "Out of range:
        - #{biomarker.name} #{out_of_range_biomarker_samples.select { |sample| sample.biomarker_id == biomarker.id }.map do |sample|
          "#{sample.value} on #{sample.issued.strftime("%B %d, %Y")} (Reference range: #{sample.reference_range})"
        end.join("")}"
        end.join("")
  else 
    "All markers in range"
  end}"
end.join("\n")}"

    biomarkers_summary
  end

  def generate_chat_suggestions(num_of_suggestions = 5)
    unused_suggestions = self.chat_suggestions.where(was_used: false).limit(5)
    used_suggestions_sample = self.chat_suggestions.where(was_used: true).limit(5)

    prompt = "Here is some high-level health information for the user: 

#{self.health_data_summary}

#{self.biomarkers_summary}

Prompts not yet used:
#{if unused_suggestions.present?
  unused_suggestions.map do |suggestion|
    "- #{suggestion.title}: #{suggestion.description}"
  end.join("\n")
else 
  "None"
end}

Prompts previously used:
#{if used_suggestions_sample.present?
  used_suggestions_sample.map do |suggestion|
    "- #{suggestion.title}: #{suggestion.description}"
  end.join("\n")
else 
  "None"
end}
"
    suggestions, model = get_chat_suggestions(prompt, num_of_suggestions)

    return if suggestions.empty? || suggestions.blank?

    suggestions.each do |suggestion|
      begin
        chat_suggestion = self.chat_suggestions.create(
          title: suggestion["title"],
          description: suggestion["description"],
          prompt: suggestion["prompt"],
          model_used: model,
        )
      rescue => e
        Rails.logger.error("Error creating chat suggestion: #{e.message}")
      end
    end
    suggestions

    # Send update notification
    self.send_chat_suggestions_updated_notification
  end

  def send_chat_suggestions_updated_notification
    notification = UserNotification.create(
      user_id: self.id,
      notification_type: :updated_chat_suggestions,
      is_background_notification: true,
    )
    self.send_notification(notification) unless !self.has_completed_onboarding
  end

  def generate_health_insights
    prompt = "Here is the latest high-level health information for the user: 

#{self.health_data_summary}

#{self.biomarkers_summary}
"

    insights = get_health_insights(prompt)

    return if insights.blank?

    health_insights = self.health_insights.find_or_initialize_by(category: HealthInsight.categories[:overall])
    health_insights.insights = insights
    health_insights.model_used = HealthInsightsService::MODEL
    health_insights.save

    # Send notification
    notification = UserNotification.create(
      user_id: self.id,
      title: "New health suggestions available",
      body: "You've got new health suggestions available! Tap to view them.",
      notification_type: :updated_health_suggestions,
      additional_data: {
        id: health_insights.id,
        updated_at: health_insights.updated_at,
      },
    )
    self.send_notification(notification) unless !self.has_completed_onboarding
  end

  def generate_daily_checkin
    conversation = Conversation.create!(user_id: self.id, last_activity_at: Time.now, is_onboarding: true)

    system_prompt = "#{default_checkin_system_prompt(self)}"
    
    system_message = {
      role: 'system',
      content: system_prompt,
    }
    chat_completion(
      self.id,
      conversation,
      [system_message],
      0.5,
      chat_functions(self.id),
    )
    
    # Send notification
    notification = UserNotification.create(
      user_id: self.id,
      title: "Daily Check-In",
      body: "Your daily check-in is now available! Tap to start a conversation.",
      notification_type: :new_message,
      additional_data: {
        conversation_id: conversation.id,
      },
    )
    self.send_notification(notification) unless !self.has_completed_onboarding
  end

  def send_notification(notification)
    if self.notification_setting.push_notifications_enabled
      send_push_notification(notification)
    end
  end

  def send_push_notification(notification)
    if self.devices.present?
      self.devices.each do |device|
        device.send_push_notification(notification)
      end
    end
  end

  def mark_notifications_as_read
    self.notifications.unread.update_all(read: true)
  end

  def generate_onboarding_conversation
    conversation = Conversation.create!(user_id: self.id, last_activity_at: Time.now, is_onboarding: true)

    system_prompt = "#{default_chat_system_prompt(self)}

Please start off by welcoming the user and letting them know how you can help them. Also, prompt them with some questions to help get them started."
    
    system_message = {
      role: 'system',
      content: system_prompt,
    }
    chat_completion(
      self.id,
      conversation,
      [system_message],
      0.5,
      chat_functions(self.id),
    )
    return conversation
  end

  # Health Data Queries
  def get_most_recent_quantity_sample(sample_type)
    self.health_quantity_samples
      .where(sample_type: sample_type)
      .order(start_date: :desc)
      .limit(1)
      .first
  end

  def get_average_quantity_sample_over_range(sample_type, start_date, end_date)
    aggregation_method = "average"
    if sample_type == "Step Count"
      aggregation_method = "sum"
    end
    samples = self.health_quantity_samples.aggregate_by_type_and_date(
      sample_type, 
      interval: "day", 
      aggregation_method: aggregation_method, 
      start_date: start_date,
      end_date: end_date,
      full_series: false
    )
    if samples.values.size > 0
      average = samples.values.sum.to_f / samples.values.size
      unit = self.get_most_recent_quantity_sample(sample_type).unit
      return { value: average, unit: unit }
    else
      return nil
    end
  end

  def get_cleaned_workouts_over_range(start_date: 1.month.ago, end_date: Time.now)
    workouts = self.workouts.over_range(start_date, end_date).order(end_date: :desc)
    workouts = Workout.remove_overlaps(workouts)
    workouts
  end

  def get_grouped_workouts(workouts, interval: :day)
    case interval
    when :day
      grouped_workouts = self.workouts.where(id: workouts.pluck(:id)).group_by_day(:end_date, reverse: true)
    when :week
      grouped_workouts = self.workouts.where(id: workouts.pluck(:id)).group_by_week(:end_date, reverse: true)
    when :month
      grouped_workouts = self.workouts.where(id: workouts.pluck(:id)).group_by_month(:end_date, reverse: true)
    when :year
      grouped_workouts = self.workouts.where(id: workouts.pluck(:id)).group_by_year(:end_date, reverse: true)
    else
      grouped_workouts = self.workouts.where(id: workouts.pluck(:id)).group_by_day(:end_date, reverse: true)
    end
    
    grouped_workouts 
  end

  def get_most_recent_sleep
    most_recent_sample = self.health_category_samples.where(
      sample_type: 'Sleep Analysis', 
      value: ['Asleep (Unspecified)', 'Core', 'Deep', 'REM']
    ).order(start_date: :desc).limit(1).first
  
    return nil unless most_recent_sample
  
    duration = 0
    last_end_date = nil
  
    samples = self.health_category_samples.where(
      sample_type: 'Sleep Analysis',
      value: ['Asleep (Unspecified)', 'Core', 'Deep', 'REM'],
    ).where('start_date <= ?', most_recent_sample.start_date).order(start_date: :desc)
    samples = HealthCategorySample.remove_overlaps(samples)
  
    samples.each do |sample|
      if last_end_date && (last_end_date - sample.end_date > 5.hours)
        # If there's a gap of more than 5 hours, stop accumulating
        break
      end
      duration += sample.end_date - sample.start_date
      last_end_date = sample.end_date
    end
  
    # Convert duration from seconds to hours
    duration_hours = duration / 3600.0
    return { value: duration_hours, date: most_recent_sample.end_date }
  end

  def average_hours_slept(start_date = 1.month.ago, end_date = Time.now)
    Rails.cache.fetch("avg_hours_slept/v1.0/#{self.cache_key_with_version}/#{start_date.strftime("%m-%d-%Y")}/#{end_date.strftime("%m-%d-%Y")}") do
      asleep_samples = self.health_category_samples.over_range(start_date, end_date)
          .where(sample_type: 'Sleep Analysis', value: ['Asleep (Unspecified)', 'Core', 'Deep', 'REM'])
      asleep_samples = HealthCategorySample.remove_overlaps(asleep_samples)
      daily_sleep_durations = asleep_samples.each_with_object(Hash.new(0)) do |sample, totals|
        date = sample.start_date.to_date
        duration = sample.end_date - sample.start_date
        totals[date] += duration
      end
      if daily_sleep_durations.blank?
        return nil
      end
      average_duration = daily_sleep_durations.values.sum / daily_sleep_durations.keys.size
      average_duration / 3600.0
    end
  end

  def average_daily_steps(start_date = 1.months.ago, end_date = Time.now)
    Rails.cache.fetch("avg_daily_steps/v1.0/#{self.cache_key_with_version}/#{start_date.strftime("%m-%d-%Y")}/#{end_date.strftime("%m-%d-%Y")}") do
      steps_per_day_last_month = HealthQuantitySummary.where(
        data_type: "Step Count", 
        summary_type: "sum", 
        user_id: self.id
      )
      .group_by_day(:date, range: start_date.beginning_of_day..end_date.end_of_day)
      .sum(:value)
      if steps_per_day_last_month.present?
        return nil if steps_per_day_last_month.size == 0
        avg_steps_per_day_last_month = steps_per_day_last_month.values.sum.to_f / steps_per_day_last_month.size
        return avg_steps_per_day_last_month
      else
        return nil
      end
    end
  end

  def average_weekly_workout_mins(start_date = 1.months.ago, end_date = Time.now)
    Rails.cache.fetch("avg_weekly_workout_mins/v1.0/#{self.cache_key_with_version}/#{start_date.strftime("%m-%d-%Y")}/#{end_date.strftime("%m-%d-%Y")}") do
      cleaned_workouts = self.get_cleaned_workouts_over_range(
        start_date: start_date.beginning_of_week, 
        end_date: end_date.end_of_week
      )
      workout_secs_per_week = self.get_grouped_workouts(cleaned_workouts, interval: :week).sum(:duration)
      if workout_secs_per_week.size > 0
        average_duration = (workout_secs_per_week.values.sum.to_f / workout_secs_per_week.size) / 60.0

        return average_duration
      else
        return nil
      end
    end
  end

  def average_bmi(start_date = 1.months.ago, end_date = Time.now)
    Rails.cache.fetch("avg_bmi/v1.0/#{self.cache_key_with_version}/#{start_date.strftime("%m-%d-%Y")}/#{end_date.strftime("%m-%d-%Y")}") do
      self.get_average_quantity_sample_over_range("Body Mass Index", start_date, end_date)
    end
  end

  def average_body_fat(start_date = 1.months.ago, end_date = Time.now)
    Rails.cache.fetch("avg_body_fat/v1.0/#{self.cache_key_with_version}/#{start_date.strftime("%m-%d-%Y")}/#{end_date.strftime("%m-%d-%Y")}") do
      self.get_average_quantity_sample_over_range("Body Fat Percentage", start_date, end_date)
    end
  end

  def average_respiratory_rate(start_date = 1.months.ago, end_date = Time.now)
    Rails.cache.fetch("avg_respiratory_rate/v1.0/#{self.cache_key_with_version}/#{start_date.strftime("%m-%d-%Y")}/#{end_date.strftime("%m-%d-%Y")}") do
      self.get_average_quantity_sample_over_range("Respiratory Rate", start_date, end_date)
    end
  end

  def average_resting_heart_rate(start_date = 1.months.ago, end_date = Time.now)
    Rails.cache.fetch("avg_resting_heart_rate/v1.0/#{self.cache_key_with_version}/#{start_date.strftime("%m-%d-%Y")}/#{end_date.strftime("%m-%d-%Y")}") do
      self.get_average_quantity_sample_over_range("Resting Heart Rate", start_date, end_date)
    end
  end

  def average_vo2_max(start_date = 1.months.ago, end_date = Time.now)
    Rails.cache.fetch("avg_vo2_max/v1.0/#{self.cache_key_with_version}/#{start_date.strftime("%m-%d-%Y")}/#{end_date.strftime("%m-%d-%Y")}") do
      self.get_average_quantity_sample_over_range("VO2 Max", start_date, end_date)
    end
  end

  def average_weight(start_date = 1.months.ago, end_date = Time.now)
    Rails.cache.fetch("avg_weight/v1.0/#{self.cache_key_with_version}/#{start_date.strftime("%m-%d-%Y")}/#{end_date.strftime("%m-%d-%Y")}") do
      self.get_average_quantity_sample_over_range("Body Mass", start_date, end_date)
    end
  end

  def create_stripe_customer
    customer = Stripe::Customer.create(
      email: self.email,
      name: self.full_name,
      phone: self.phone_number,
    )
    self.stripe_customer_id = customer.id
    self.save
  end

  def update_stripe_customer
    update_params = {}
  
    if self.saved_change_to_email? && self.email_verified?
      update_params[:email] = self.email
    end
  
    if self.saved_change_to_first_name? || self.saved_change_to_last_name?
      update_params[:name] = self.full_name
    end
  
    if self.saved_change_to_phone_number? && self.phone_number_verified?
      update_params[:phone] = self.phone_number
    end

    if self.saved_change_to_address_line_1? || self.saved_change_to_address_line_2? || self.saved_change_to_city? || self.saved_change_to_state? || self.saved_change_to_zip_code? || self.saved_change_to_country?
      update_params[:address] = {
        line1: self.address_line_1,
        line2: self.address_line_2,
        city: self.city,
        state: self.state,
        postal_code: self.zip_code,
        country: self.country,
      }
    end
  
    # Only call Stripe::Customer.update if there are parameters to update and the user has a Stripe customer ID
    if update_params.present? && self.stripe_customer_id.present?
      Stripe::Customer.update(self.stripe_customer_id, update_params)
    else
      # Create a new Stripe customer if the user doesn't have a Stripe customer ID yet
      create_stripe_customer unless self.stripe_customer_id.present?
    end
  end

  def send_new_lab_results_notification(new_lab_results_ids)
    Rails.logger.info("Creating lab result notifications for user #{id} and lab result ids #{new_lab_results_ids}")
    lab_results_count = new_lab_results_ids.size
    message = "You have #{lab_results_count} new lab result#{lab_results_count > 1 ? 's' : ''} available."
    notification = UserNotification.create(
      user_id: id,
      title: "New Lab Results",
      body: message,
      notification_type: :new_lab_results,
      additional_data: {
        title: "New Lab Results",
        message: message,
        chat_prompt: "I'd like to review my latest lab results.",
      }
    )
    send_notification(notification) unless !has_completed_onboarding
  end

  def has_consent_for?(consent_type)
    self.user_consents.where(consent_type: consent_type).exists?
  end


  private

  def create_notification_settings
    NotificationSetting.create(user_id: self.id)
  end

  def create_health_profile
    HealthProfile.create(user_id: self.id)
  end

  def process_samples(samples)
    daily_totals = Hash.new { |hash, key| hash[key] = [] }

    samples.each do |sample|
      date = sample.start_date.to_date
      add_sample_to_daily_total(sample, daily_totals[date])
    end

    daily_totals.transform_values { |intervals| intervals.sum(&:last) }
  end

  def add_sample_to_daily_total(sample, intervals)
    interval = [sample.start_date, sample.end_date, sample.value]

    overlapping = intervals.any? do |existing_interval|
      sample_overlap?(existing_interval, interval)
    end

    intervals << interval unless overlapping
  end

  def sample_overlap?(interval1, interval2)
    interval1.first < interval2.second && interval1.second > interval2.first
  end

  def update_profile_picture
    if picture.present?
      begin
        uri = URI.parse(picture)
        file_extension = File.extname(uri.path)
        content_type = MIME::Types.type_for(uri.path).first.content_type
        file_name = File.basename(uri.path)

        downloaded_image = URI.open(picture)
        profile_picture.attach(io: downloaded_image, filename: "#{id}_#{file_name.presence}" || "#{id}_profile#{file_extension}", content_type: content_type.presence || "image/jpeg")
      rescue OpenURI::HTTPError, URI::InvalidURIError => e
        Rails.logger.error "Failed to download or attach profile picture: #{e.message}"
        Sentry.capture_exception(e)
      end
    else
      # Remove the profile_picture if picture URL is nil or empty
      profile_picture.purge_later if profile_picture.attached?
    end
  end
end
