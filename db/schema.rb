# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140724154316) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_trgm"
  enable_extension "fuzzystrmatch"
  enable_extension "btree_gist"

  create_table "paragraphs", force: true do |t|
    t.integer  "person_id"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "paragraphs", ["person_id"], name: "index_paragraphs_on_person_id", using: :btree
  add_index "paragraphs", ["text"], name: "text_trigram_index", using: :gin

  create_table "people", force: true do |t|
    t.string   "name"
    t.string   "href"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "people", ["name"], name: "name_trigram_index", using: :gin

end
