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

ActiveRecord::Schema[7.0].define(version: 2023_08_03_003426) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "frequency_table_entries", force: :cascade do |t|
    t.string "content"
    t.string "kana"
    t.integer "frequency"
    t.bigint "frequency_table_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["frequency_table_id"], name: "index_frequency_table_entries_on_frequency_table_id"
  end

  create_table "frequency_tables", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "word_frequencies", force: :cascade do |t|
    t.integer "frequency"
    t.bigint "word_id", null: false
    t.bigint "frequency_table_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["frequency_table_id"], name: "index_word_frequencies_on_frequency_table_id"
    t.index ["word_id"], name: "index_word_frequencies_on_word_id"
  end

  create_table "word_sets", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.bigint "word_set_id", null: false
    t.index ["word_set_id"], name: "index_words_on_word_set_id"
  end

  add_foreign_key "frequency_table_entries", "frequency_tables"
  add_foreign_key "word_frequencies", "frequency_tables"
  add_foreign_key "word_frequencies", "words"
  add_foreign_key "word_tags", "tags"
  add_foreign_key "word_tags", "words"
  add_foreign_key "words", "word_sets"
end
