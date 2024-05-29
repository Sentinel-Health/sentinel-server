# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_05_16_231739) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "allergies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "clinical_record_id", null: false
    t.string "name"
    t.string "status"
    t.datetime "recorded_on"
    t.boolean "is_archived", default: false
    t.datetime "archived_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["clinical_record_id"], name: "index_allergies_on_clinical_record_id"
    t.index ["user_id"], name: "index_allergies_on_user_id"
  end

  create_table "biomarker_categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "biomarker_subcategories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "biomarker_category_id", null: false
    t.string "name", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["biomarker_category_id"], name: "index_biomarker_subcategories_on_biomarker_category_id"
  end

  create_table "biomarkers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "biomarker_subcategory_id", null: false
    t.string "name", null: false
    t.string "description"
    t.string "unit"
    t.string "alternative_names", default: [], null: false, array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["biomarker_subcategory_id"], name: "index_biomarkers_on_biomarker_subcategory_id"
  end

  create_table "chat_feedbacks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "message_id", null: false
    t.string "feedback_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_id"], name: "index_chat_feedbacks_on_message_id"
    t.index ["user_id"], name: "index_chat_feedbacks_on_user_id"
  end

  create_table "chat_suggestions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "model_used"
    t.boolean "was_used", default: false
    t.string "title"
    t.string "description"
    t.string "prompt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_chat_suggestions_on_user_id"
  end

  create_table "clinical_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "record_type"
    t.string "identifier", null: false
    t.string "source_name"
    t.string "source_version"
    t.string "fhir_release"
    t.string "fhir_version"
    t.datetime "received_date"
    t.text "fhir_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["identifier"], name: "index_clinical_records_on_identifier", unique: true
    t.index ["user_id"], name: "index_clinical_records_on_user_id"
  end

  create_table "condition_histories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "clinical_record_id", null: false
    t.uuid "condition_id", null: false
    t.string "name"
    t.string "status"
    t.datetime "recorded_on"
    t.string "recorded_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["clinical_record_id"], name: "index_condition_histories_on_clinical_record_id"
    t.index ["condition_id"], name: "index_condition_histories_on_condition_id"
  end

  create_table "conditions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "name"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "archived_at"
    t.boolean "is_archived", default: false
    t.index ["user_id"], name: "index_conditions_on_user_id"
  end

  create_table "console1984_commands", force: :cascade do |t|
    t.text "statements"
    t.bigint "sensitive_access_id"
    t.bigint "session_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sensitive_access_id"], name: "index_console1984_commands_on_sensitive_access_id"
    t.index ["session_id", "created_at", "sensitive_access_id"], name: "on_session_and_sensitive_chronologically"
  end

  create_table "console1984_sensitive_accesses", force: :cascade do |t|
    t.text "justification"
    t.bigint "session_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_console1984_sensitive_accesses_on_session_id"
  end

  create_table "console1984_sessions", force: :cascade do |t|
    t.text "reason"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_console1984_sessions_on_created_at"
    t.index ["user_id", "created_at"], name: "index_console1984_sessions_on_user_id_and_created_at"
  end

  create_table "console1984_users", force: :cascade do |t|
    t.string "username", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["username"], name: "index_console1984_users_on_username"
  end

  create_table "conversations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.datetime "last_activity_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "title"
    t.string "summary"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_onboarding", default: false
    t.index ["user_id"], name: "index_conversations_on_user_id"
  end

  create_table "devices", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "token"
    t.string "device_type"
    t.string "aws_platform_endpoint_arn"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_devices_on_user_id"
  end

  create_table "health_category_samples", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "sample_type", null: false
    t.string "value", null: false
    t.string "identifier", null: false
    t.string "source_name"
    t.string "source_version"
    t.string "device"
    t.datetime "start_date"
    t.datetime "end_date"
    t.json "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "identifier"], name: "index_health_category_samples_on_user_id_and_identifier", unique: true
    t.index ["user_id"], name: "index_health_category_samples_on_user_id"
  end

  create_table "health_insights", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "category", default: "unknown", null: false
    t.string "model_used"
    t.json "insights"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_health_insights_on_user_id"
  end

  create_table "health_profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.text "dob"
    t.text "sex"
    t.text "blood_type"
    t.text "skin_type"
    t.text "wheelchair_use"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "legal_first_name"
    t.text "legal_last_name"
    t.index ["user_id"], name: "index_health_profiles_on_user_id"
  end

  create_table "health_quantity_samples", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "sample_type", null: false
    t.string "unit"
    t.float "value", null: false
    t.string "identifier", null: false
    t.string "source_name"
    t.string "source_version"
    t.string "device"
    t.datetime "start_date"
    t.datetime "end_date"
    t.json "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "identifier"], name: "index_health_quantity_samples_on_user_id_and_identifier", unique: true
    t.index ["user_id"], name: "index_health_quantity_samples_on_user_id"
  end

  create_table "health_quantity_summaries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "data_type", null: false
    t.string "summary_type", null: false
    t.string "unit"
    t.float "value", null: false
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "data_type", "summary_type", "date"], name: "idx_on_user_id_data_type_summary_type_date_ad6ef49d0f", unique: true
    t.index ["user_id"], name: "index_health_quantity_summaries_on_user_id"
  end

  create_table "health_summaries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "category", default: "unknown", null: false
    t.string "summary", null: false
    t.string "model_used"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_health_summaries_on_user_id"
  end

  create_table "immunizations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "clinical_record_id", null: false
    t.string "name"
    t.date "received_on"
    t.boolean "is_archived", default: false
    t.datetime "archived_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["clinical_record_id"], name: "index_immunizations_on_clinical_record_id"
    t.index ["user_id"], name: "index_immunizations_on_user_id"
  end

  create_table "lab_results", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "clinical_record_id"
    t.string "name"
    t.datetime "issued"
    t.string "value"
    t.string "reference_range"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "value_quantity"
    t.string "unit"
    t.jsonb "reference_range_json", default: {}
    t.uuid "lab_test_order_id"
    t.uuid "biomarker_id"
    t.index ["biomarker_id"], name: "index_lab_results_on_biomarker_id"
    t.index ["clinical_record_id"], name: "index_lab_results_on_clinical_record_id"
    t.index ["lab_test_order_id"], name: "index_lab_results_on_lab_test_order_id"
    t.index ["user_id"], name: "index_lab_results_on_user_id"
  end

  create_table "lab_test_biomarkers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "lab_test_id", null: false
    t.uuid "biomarker_id", null: false
    t.json "loinic_info"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["biomarker_id"], name: "index_lab_test_biomarkers_on_biomarker_id"
    t.index ["lab_test_id"], name: "index_lab_test_biomarkers_on_lab_test_id"
  end

  create_table "lab_test_orders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "lab_test_id", null: false
    t.string "stripe_checkout_session_id"
    t.string "vital_order_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", default: "received", null: false
    t.decimal "amount", precision: 19, scale: 4, default: "0.0", null: false
    t.string "currency", default: "USD", null: false
    t.string "detailed_status"
    t.boolean "results_have_been_viewed", default: false
    t.string "results_status", default: "final"
    t.datetime "results_reported_at"
    t.datetime "results_collected_at"
    t.bigint "order_number"
    t.index ["lab_test_id"], name: "index_lab_test_orders_on_lab_test_id"
    t.index ["order_number"], name: "index_lab_test_orders_on_order_number", unique: true
    t.index ["user_id"], name: "index_lab_test_orders_on_user_id"
  end

  create_table "lab_tests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "short_description", null: false
    t.string "status", default: "inactive", null: false
    t.string "category", default: "standard", null: false
    t.string "collection_method", default: "walk_in_test", null: false
    t.string "sample_type", default: "serum", null: false
    t.boolean "is_fasting_required", default: true, null: false
    t.decimal "price", precision: 19, scale: 4, null: false
    t.string "currency", default: "USD", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "vital_lab_test_id"
    t.string "stripe_product_id"
    t.text "markdown_description", default: "", null: false
    t.uuid "lab_id"
    t.integer "order", default: 0
    t.boolean "has_biotin_interference_potential", default: false, null: false
    t.index ["lab_id"], name: "index_lab_tests_on_lab_id"
  end

  create_table "labs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.string "country"
    t.string "phone_number"
    t.string "support_email"
    t.string "website"
    t.string "appointment_url"
    t.string "collection_methods", default: [], array: true
    t.string "sample_types", default: [], array: true
    t.integer "vital_lab_id"
    t.string "vital_lab_slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "medications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "clinical_record_id", null: false
    t.uuid "user_id", null: false
    t.string "name"
    t.string "dosage_instructions"
    t.string "status"
    t.datetime "authored_on"
    t.string "authored_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "archived_at"
    t.boolean "is_archived", default: false
    t.index ["clinical_record_id"], name: "index_medications_on_clinical_record_id"
    t.index ["user_id"], name: "index_medications_on_user_id"
  end

  create_table "messages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "conversation_id", null: false
    t.string "name"
    t.string "role", null: false
    t.string "content"
    t.json "function_call"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "tool_call_id"
    t.json "tool_calls"
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
  end

  create_table "notification_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.boolean "push_notifications_enabled", default: false
    t.boolean "email_notifications_enabled", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "daily_checkin", default: false
    t.time "daily_checkin_time", default: "2000-01-01 21:00:00"
    t.index ["user_id"], name: "index_notification_settings_on_user_id"
  end

  create_table "procedures", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "clinical_record_id", null: false
    t.string "name"
    t.string "status"
    t.date "performed_on"
    t.boolean "is_archived", default: false
    t.datetime "archived_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["clinical_record_id"], name: "index_procedures_on_clinical_record_id"
    t.index ["user_id"], name: "index_procedures_on_user_id"
  end

  create_table "session_audit_trails", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.string "event"
    t.string "ip_address"
    t.string "user_agent"
    t.string "device"
    t.string "platform"
    t.json "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_session_audit_trails_on_user_id"
  end

  create_table "sessions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "access_token", null: false
    t.integer "exp"
    t.integer "iat"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "refresh_token"
    t.string "ip_address"
    t.string "device"
    t.string "platform"
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "taggings", force: :cascade do |t|
    t.bigint "tag_id"
    t.string "taggable_type"
    t.uuid "taggable_id"
    t.string "tagger_type"
    t.uuid "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at", precision: nil
    t.string "tenant", limit: 128
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable_type_and_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
    t.index ["tagger_type", "tagger_id"], name: "index_taggings_on_tagger_type_and_tagger_id"
    t.index ["tenant"], name: "index_taggings_on_tenant"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "user_consents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "consent_type"
    t.datetime "consented_at"
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_consents_on_user_id"
  end

  create_table "user_notifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "title"
    t.string "body"
    t.string "action"
    t.json "action_data"
    t.boolean "read", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "additional_data"
    t.string "notification_type", default: "generic", null: false
    t.boolean "is_background_notification", default: false
    t.index ["user_id"], name: "index_user_notifications_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "first_name"
    t.text "last_name"
    t.text "email", null: false
    t.boolean "email_verified", default: false
    t.text "phone_number"
    t.text "picture"
    t.boolean "has_completed_onboarding", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_syncing_health_data", default: false
    t.datetime "data_sync_started_at"
    t.datetime "data_sync_completed_at"
    t.string "timezone", default: "America/Los_Angeles", null: false
    t.string "stripe_customer_id"
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.string "country"
    t.boolean "phone_number_verified", default: false
    t.string "vital_user_id"
    t.jsonb "health_goals", default: {}
    t.string "role", default: "member", null: false
  end

  create_table "vital_lab_test_results", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "vital_order_id", null: false
    t.text "results_data"
    t.datetime "date_reported", null: false
    t.datetime "date_received"
    t.datetime "date_collected"
    t.string "specimen_number", null: false
    t.string "status"
    t.string "interpretation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_vital_lab_test_results_on_user_id"
  end

  create_table "webhooks_incoming_stripe_webhooks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.jsonb "data"
    t.datetime "processed_at"
    t.datetime "verified_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "webhooks_incoming_vital_webhooks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.jsonb "data"
    t.datetime "processed_at"
    t.datetime "verified_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "workouts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "identifier", null: false
    t.string "activity_type"
    t.float "duration"
    t.string "duration_unit"
    t.float "total_distance"
    t.string "total_distance_unit"
    t.float "total_energy_burned"
    t.string "total_energy_burned_unit"
    t.string "source_name"
    t.string "source_version"
    t.string "device"
    t.datetime "start_date"
    t.datetime "end_date"
    t.json "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "identifier"], name: "index_workouts_on_user_id_and_identifier", unique: true
    t.index ["user_id"], name: "index_workouts_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "allergies", "clinical_records"
  add_foreign_key "allergies", "users"
  add_foreign_key "biomarker_subcategories", "biomarker_categories"
  add_foreign_key "biomarkers", "biomarker_subcategories"
  add_foreign_key "chat_feedbacks", "messages"
  add_foreign_key "chat_feedbacks", "users"
  add_foreign_key "chat_suggestions", "users"
  add_foreign_key "clinical_records", "users"
  add_foreign_key "condition_histories", "clinical_records"
  add_foreign_key "condition_histories", "conditions"
  add_foreign_key "conditions", "users"
  add_foreign_key "conversations", "users"
  add_foreign_key "devices", "users"
  add_foreign_key "health_category_samples", "users"
  add_foreign_key "health_insights", "users"
  add_foreign_key "health_profiles", "users"
  add_foreign_key "health_quantity_samples", "users"
  add_foreign_key "health_quantity_summaries", "users"
  add_foreign_key "health_summaries", "users"
  add_foreign_key "immunizations", "clinical_records"
  add_foreign_key "immunizations", "users"
  add_foreign_key "lab_results", "biomarkers"
  add_foreign_key "lab_results", "clinical_records"
  add_foreign_key "lab_results", "lab_test_orders"
  add_foreign_key "lab_results", "users"
  add_foreign_key "lab_test_biomarkers", "biomarkers"
  add_foreign_key "lab_test_biomarkers", "lab_tests"
  add_foreign_key "lab_test_orders", "lab_tests"
  add_foreign_key "lab_test_orders", "users"
  add_foreign_key "lab_tests", "labs"
  add_foreign_key "medications", "clinical_records"
  add_foreign_key "medications", "users"
  add_foreign_key "messages", "conversations"
  add_foreign_key "notification_settings", "users"
  add_foreign_key "procedures", "clinical_records"
  add_foreign_key "procedures", "users"
  add_foreign_key "session_audit_trails", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "taggings", "tags"
  add_foreign_key "user_consents", "users"
  add_foreign_key "user_notifications", "users"
  add_foreign_key "vital_lab_test_results", "users"
  add_foreign_key "workouts", "users"
end
