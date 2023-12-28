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

ActiveRecord::Schema[7.1].define(version: 2023_12_28_160517) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "audits", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.jsonb "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "batches", force: :cascade do |t|
    t.string "name"
    t.date "expiry"
    t.bigint "vaccine_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["vaccine_id"], name: "index_batches_on_vaccine_id"
  end

  create_table "campaigns", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "team_id"
  end

  create_table "campaigns_vaccines", id: false, force: :cascade do |t|
    t.bigint "campaign_id", null: false
    t.bigint "vaccine_id", null: false
    t.index ["campaign_id", "vaccine_id"], name: "index_campaigns_vaccines_on_campaign_id_and_vaccine_id"
    t.index ["vaccine_id", "campaign_id"], name: "index_campaigns_vaccines_on_vaccine_id_and_campaign_id"
  end

  create_table "consent_forms", force: :cascade do |t|
    t.bigint "session_id", null: false
    t.datetime "recorded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "first_name"
    t.text "last_name"
    t.boolean "use_common_name"
    t.text "common_name"
    t.date "date_of_birth"
    t.string "parent_name"
    t.integer "parent_relationship"
    t.string "parent_relationship_other"
    t.string "parent_email"
    t.string "parent_phone"
    t.integer "contact_method"
    t.text "contact_method_other"
    t.integer "response"
    t.integer "reason"
    t.text "reason_notes"
    t.boolean "contact_injection"
    t.string "gp_name"
    t.integer "gp_response"
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_town"
    t.string "address_postcode"
    t.jsonb "health_answers", default: [], null: false
    t.bigint "consent_id"
    t.index ["consent_id"], name: "index_consent_forms_on_consent_id"
    t.index ["session_id"], name: "index_consent_forms_on_session_id"
  end

  create_table "consents", force: :cascade do |t|
    t.bigint "patient_id", null: false
    t.bigint "campaign_id", null: false
    t.text "childs_name"
    t.text "childs_common_name"
    t.date "childs_dob"
    t.text "address_line_1"
    t.text "address_line_2"
    t.text "address_town"
    t.text "address_postcode"
    t.text "parent_name"
    t.integer "parent_relationship"
    t.text "parent_relationship_other"
    t.text "parent_email"
    t.text "parent_phone"
    t.integer "parent_contact_method"
    t.text "parent_contact_method_other"
    t.integer "response"
    t.integer "reason_for_refusal"
    t.text "reason_for_refusal_other"
    t.integer "gp_response"
    t.text "gp_name"
    t.integer "route", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "health_questions"
    t.datetime "recorded_at"
    t.jsonb "health_answers", default: [], null: false
    t.index ["campaign_id"], name: "index_consents_on_campaign_id"
    t.index ["patient_id"], name: "index_consents_on_patient_id"
  end

  create_table "flipper_features", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_flipper_features_on_key", unique: true
  end

  create_table "flipper_gates", force: :cascade do |t|
    t.string "feature_key", null: false
    t.string "key", null: false
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["feature_key", "key", "value"], name: "index_flipper_gates_on_feature_key_and_key_and_value", unique: true
  end

  create_table "good_job_batches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.jsonb "serialized_properties"
    t.text "on_finish"
    t.text "on_success"
    t.text "on_discard"
    t.text "callback_queue_name"
    t.integer "callback_priority"
    t.datetime "enqueued_at"
    t.datetime "discarded_at"
    t.datetime "finished_at"
  end

  create_table "good_job_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id", null: false
    t.text "job_class"
    t.text "queue_name"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.text "error"
    t.integer "error_event", limit: 2
    t.index ["active_job_id", "created_at"], name: "index_good_job_executions_on_active_job_id_and_created_at"
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "state"
  end

  create_table "good_job_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "key"
    t.jsonb "value"
    t.index ["key"], name: "index_good_job_settings_on_key", unique: true
  end

  create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "queue_name"
    t.integer "priority"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "performed_at"
    t.datetime "finished_at"
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id"
    t.text "concurrency_key"
    t.text "cron_key"
    t.uuid "retried_good_job_id"
    t.datetime "cron_at"
    t.uuid "batch_id"
    t.uuid "batch_callback_id"
    t.boolean "is_discrete"
    t.integer "executions_count"
    t.text "job_class"
    t.integer "error_event", limit: 2
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["active_job_id"], name: "index_good_jobs_on_active_job_id"
    t.index ["batch_callback_id"], name: "index_good_jobs_on_batch_callback_id", where: "(batch_callback_id IS NOT NULL)"
    t.index ["batch_id"], name: "index_good_jobs_on_batch_id", where: "(batch_id IS NOT NULL)"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at", unique: true
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at", where: "((retried_good_job_id IS NULL) AND (finished_at IS NOT NULL))"
    t.index ["priority", "created_at"], name: "index_good_jobs_jobs_on_priority_created_at_when_unfinished", order: { priority: "DESC NULLS LAST" }, where: "(finished_at IS NULL)"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
  end

  create_table "health_questions", force: :cascade do |t|
    t.string "question"
    t.bigint "vaccine_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "hint"
    t.jsonb "metadata", default: {}, null: false
    t.bigint "follow_up_question_id"
    t.bigint "next_question_id"
    t.index ["follow_up_question_id"], name: "index_health_questions_on_follow_up_question_id"
    t.index ["next_question_id"], name: "index_health_questions_on_next_question_id"
    t.index ["vaccine_id"], name: "index_health_questions_on_vaccine_id"
  end

  create_table "locations", force: :cascade do |t|
    t.text "name"
    t.text "address"
    t.text "locality"
    t.text "town"
    t.text "county"
    t.text "postcode"
    t.text "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "offline_passwords", force: :cascade do |t|
    t.string "password", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "patient_sessions", force: :cascade do |t|
    t.bigint "session_id", null: false
    t.bigint "patient_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "state"
    t.boolean "gillick_competent"
    t.text "gillick_competence_notes"
    t.index ["patient_id", "session_id"], name: "index_patient_sessions_on_patient_id_and_session_id", unique: true
    t.index ["session_id", "patient_id"], name: "index_patient_sessions_on_session_id_and_patient_id", unique: true
  end

  create_table "patients", force: :cascade do |t|
    t.date "dob"
    t.bigint "nhs_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sex"
    t.text "first_name"
    t.text "last_name"
    t.text "preferred_name"
    t.integer "screening"
    t.integer "consent"
    t.integer "seen"
    t.text "parent_name"
    t.integer "parent_relationship"
    t.text "parent_relationship_other"
    t.text "parent_email"
    t.text "parent_phone"
    t.text "parent_info_source"
    t.index ["nhs_number"], name: "index_patients_on_nhs_number", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "date"
    t.bigint "location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "name", null: false
    t.bigint "campaign_id", null: false
    t.index ["campaign_id"], name: "index_sessions_on_campaign_id"
  end

  create_table "teams", force: :cascade do |t|
    t.text "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_teams_on_name", unique: true
  end

  create_table "teams_users", id: false, force: :cascade do |t|
    t.bigint "team_id", null: false
    t.bigint "user_id", null: false
    t.index ["team_id", "user_id"], name: "index_teams_users_on_team_id_and_user_id"
    t.index ["user_id", "team_id"], name: "index_teams_users_on_user_id_and_team_id"
  end

  create_table "triage", force: :cascade do |t|
    t.integer "status"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "patient_session_id"
    t.bigint "user_id"
    t.index ["patient_session_id"], name: "index_triage_on_patient_session_id"
    t.index ["user_id"], name: "index_triage_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "full_name"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vaccination_records", force: :cascade do |t|
    t.bigint "patient_session_id", null: false
    t.datetime "recorded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "delivery_site"
    t.boolean "administered"
    t.integer "reason"
    t.bigint "batch_id"
    t.integer "delivery_method"
    t.bigint "user_id"
    t.text "notes"
    t.index ["batch_id"], name: "index_vaccination_records_on_batch_id"
    t.index ["patient_session_id"], name: "index_vaccination_records_on_patient_session_id"
    t.index ["user_id"], name: "index_vaccination_records_on_user_id"
  end

  create_table "vaccines", force: :cascade do |t|
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "brand"
    t.integer "method"
    t.index ["type"], name: "index_vaccines_on_type", unique: true
  end

  add_foreign_key "batches", "vaccines"
  add_foreign_key "campaigns", "teams"
  add_foreign_key "consent_forms", "consents"
  add_foreign_key "consent_forms", "sessions"
  add_foreign_key "consents", "campaigns"
  add_foreign_key "consents", "patients"
  add_foreign_key "health_questions", "health_questions", column: "follow_up_question_id"
  add_foreign_key "health_questions", "health_questions", column: "next_question_id"
  add_foreign_key "health_questions", "vaccines"
  add_foreign_key "triage", "patient_sessions"
  add_foreign_key "triage", "users"
  add_foreign_key "vaccination_records", "batches"
  add_foreign_key "vaccination_records", "patient_sessions"
  add_foreign_key "vaccination_records", "users"
end
