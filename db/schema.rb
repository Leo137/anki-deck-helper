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

ActiveRecord::Schema[7.0].define(version: 2026_06_14_130000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "deck_card_fields", force: :cascade do |t|
    t.bigint "deck_card_id", null: false
    t.integer "side", null: false
    t.text "html_content", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deck_card_id", "side"], name: "index_deck_card_fields_on_deck_card_id_and_side", unique: true
    t.index ["deck_card_id"], name: "index_deck_card_fields_on_deck_card_id"
  end

  create_table "deck_cards", force: :cascade do |t|
    t.bigint "deck_id", null: false
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deck_id", "position"], name: "index_deck_cards_on_deck_id_and_position", unique: true
    t.index ["deck_id"], name: "index_deck_cards_on_deck_id"
  end

  create_table "decks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0, null: false
    t.text "error_message"
    t.integer "generation_progress", default: 0, null: false
    t.integer "generation_total"
    t.index ["user_id", "name"], name: "index_decks_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_decks_on_user_id"
  end

  create_table "dictionaries", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "language_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["language_id"], name: "index_dictionaries_on_language_id"
    t.index ["name", "language_id"], name: "index_dictionaries_on_name_and_language_id", unique: true
  end

  create_table "dictionary_entries", force: :cascade do |t|
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "jmdict_id"
    t.index ["text"], name: "index_dictionary_entries_on_text"
  end

  create_table "dictionary_meaning_definitions", force: :cascade do |t|
    t.bigint "dictionary_meaning_id", null: false
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dictionary_meaning_id"], name: "index_dict_mean_definitions"
  end

  create_table "dictionary_meaning_fields", force: :cascade do |t|
    t.bigint "dictionary_meaning_id", null: false
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dictionary_meaning_id"], name: "index_dict_mean_fields"
  end

  create_table "dictionary_meaning_misc_tags", force: :cascade do |t|
    t.bigint "dictionary_meaning_id", null: false
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dictionary_meaning_id"], name: "index_dict_mean_misctags"
  end

  create_table "dictionary_meaning_part_of_speeches", force: :cascade do |t|
    t.bigint "dictionary_meaning_id", null: false
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dictionary_meaning_id"], name: "index_dict_mean_partofspeeches"
  end

  create_table "dictionary_meanings", force: :cascade do |t|
    t.bigint "dictionary_entry_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "dictionary_id"
    t.index ["dictionary_entry_id"], name: "index_dictionary_meanings_on_dictionary_entry_id"
    t.index ["dictionary_id"], name: "index_dictionary_meanings_on_dictionary_id"
  end

  create_table "dictionary_readings", force: :cascade do |t|
    t.bigint "dictionary_entry_id", null: false
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_kana", default: false
    t.index ["dictionary_entry_id"], name: "index_dictionary_readings_on_dictionary_entry_id"
  end

  create_table "frequency_table_entries", force: :cascade do |t|
    t.string "content"
    t.string "kana"
    t.integer "frequency"
    t.bigint "frequency_table_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["content", "frequency_table_id"], name: "index_frequency_table_entries_on_content_and_frequency_table_id", unique: true
    t.index ["content"], name: "index_frequency_table_entries_on_content"
    t.index ["frequency"], name: "index_frequency_table_entries_on_frequency"
    t.index ["frequency_table_id"], name: "index_frequency_table_entries_on_frequency_table_id"
  end

  create_table "frequency_tables", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "max_frequency"
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
    t.text "error_backtrace", array: true
    t.uuid "process_id"
    t.interval "duration"
    t.index ["active_job_id", "created_at"], name: "index_good_job_executions_on_active_job_id_and_created_at"
    t.index ["process_id", "created_at"], name: "index_good_job_executions_on_process_id_and_created_at"
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "state"
    t.integer "lock_type", limit: 2
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
    t.text "labels", array: true
    t.uuid "locked_by_id"
    t.datetime "locked_at"
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["batch_callback_id"], name: "index_good_jobs_on_batch_callback_id", where: "(batch_callback_id IS NOT NULL)"
    t.index ["batch_id"], name: "index_good_jobs_on_batch_id", where: "(batch_id IS NOT NULL)"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at_cond", where: "(cron_key IS NOT NULL)"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at_cond", unique: true, where: "(cron_key IS NOT NULL)"
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at", where: "((retried_good_job_id IS NULL) AND (finished_at IS NOT NULL))"
    t.index ["labels"], name: "index_good_jobs_on_labels", where: "(labels IS NOT NULL)", using: :gin
    t.index ["locked_by_id"], name: "index_good_jobs_on_locked_by_id", where: "(locked_by_id IS NOT NULL)"
    t.index ["priority", "created_at"], name: "index_good_job_jobs_for_candidate_lookup", where: "(finished_at IS NULL)"
    t.index ["priority", "created_at"], name: "index_good_jobs_jobs_on_priority_created_at_when_unfinished", order: { priority: "DESC NULLS LAST" }, where: "(finished_at IS NULL)"
    t.index ["priority", "scheduled_at"], name: "index_good_jobs_on_priority_scheduled_at_unfinished_unlocked", where: "((finished_at IS NULL) AND (locked_by_id IS NULL))"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
  end

  create_table "jwt_denylists", force: :cascade do |t|
    t.string "jti", null: false
    t.datetime "exp", null: false
    t.index ["jti"], name: "index_jwt_denylists_on_jti"
  end

  create_table "languages", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_languages_on_code", unique: true
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "username", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "preferred_language", default: "en", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "word_frequencies", force: :cascade do |t|
    t.integer "frequency"
    t.bigint "word_id", null: false
    t.bigint "frequency_table_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["frequency_table_id"], name: "index_word_frequencies_on_frequency_table_id"
    t.index ["word_id", "frequency_table_id"], name: "index_word_frequencies_on_word_id_and_frequency_table_id", unique: true
    t.index ["word_id"], name: "index_word_frequencies_on_word_id"
  end

  create_table "word_sets", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "origin", default: 0, null: false
    t.index ["name", "origin"], name: "index_word_sets_on_name_and_origin", unique: true
  end

  create_table "word_sets_words", id: false, force: :cascade do |t|
    t.bigint "word_id", null: false
    t.bigint "word_set_id", null: false
  end

  create_table "word_tags", force: :cascade do |t|
    t.bigint "word_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id"], name: "index_word_tags_on_tag_id"
    t.index ["word_id"], name: "index_word_tags_on_word_id"
  end

  create_table "words", force: :cascade do |t|
    t.string "content"
    t.string "kana"
    t.datetime "exported_at"
    t.datetime "added_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "word_count", default: 0
    t.index ["content"], name: "index_words_on_content"
  end

  add_foreign_key "deck_card_fields", "deck_cards"
  add_foreign_key "deck_cards", "decks"
  add_foreign_key "decks", "users"
  add_foreign_key "dictionaries", "languages"
  add_foreign_key "dictionary_meaning_definitions", "dictionary_meanings"
  add_foreign_key "dictionary_meaning_fields", "dictionary_meanings"
  add_foreign_key "dictionary_meaning_misc_tags", "dictionary_meanings"
  add_foreign_key "dictionary_meaning_part_of_speeches", "dictionary_meanings"
  add_foreign_key "dictionary_meanings", "dictionaries"
  add_foreign_key "dictionary_meanings", "dictionary_entries"
  add_foreign_key "dictionary_readings", "dictionary_entries"
  add_foreign_key "frequency_table_entries", "frequency_tables"
  add_foreign_key "word_frequencies", "frequency_tables"
  add_foreign_key "word_frequencies", "words"
  add_foreign_key "word_tags", "tags"
  add_foreign_key "word_tags", "words"
end
