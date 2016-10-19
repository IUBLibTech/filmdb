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

ActiveRecord::Schema.define(version: 20161019180740) do

  create_table "collection_inventory_configurations", force: :cascade do |t|
    t.integer  "collection_id",              limit: 8
    t.boolean  "location"
    t.boolean  "copy_right"
    t.boolean  "series_name"
    t.boolean  "series_production_number"
    t.boolean  "series_part"
    t.boolean  "alternative_title"
    t.boolean  "title_version"
    t.boolean  "item_original_identifier"
    t.boolean  "summary"
    t.boolean  "creator"
    t.boolean  "distributors"
    t.boolean  "credits"
    t.boolean  "language"
    t.boolean  "accompanying_documentation"
    t.boolean  "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "collections", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "unit_id",    limit: 8
  end

  create_table "physical_object_old_barcodes", force: :cascade do |t|
    t.integer  "physical_object_id", limit: 8
    t.integer  "iu_barcode",         limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "physical_objects", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "date_inventoried"
    t.integer  "inventoried_by",             limit: 8
    t.string   "location",                   limit: 255
    t.integer  "collection_id",              limit: 8
    t.string   "media_type",                 limit: 255
    t.integer  "iu_barcode",                 limit: 8,     null: false
    t.integer  "copy_right",                 limit: 4
    t.string   "format",                     limit: 255
    t.integer  "spreadsheet_id",             limit: 4
    t.string   "series_name",                limit: 255
    t.string   "series_production_number",   limit: 255
    t.string   "series_part",                limit: 255
    t.string   "alternative_title",          limit: 255
    t.string   "title_version",              limit: 255
    t.string   "item_original_identifier",   limit: 255
    t.text     "summary",                    limit: 65535
    t.string   "creator",                    limit: 255
    t.string   "distributors",               limit: 255
    t.string   "credits",                    limit: 255
    t.string   "language",                   limit: 255
    t.text     "accompanying_documentation", limit: 65535
    t.text     "notes",                      limit: 65535
    t.integer  "unit_id",                    limit: 8
    t.string   "medium",                     limit: 255
    t.integer  "title_id",                   limit: 8
  end

  create_table "series", force: :cascade do |t|
    t.string   "title",       limit: 255
    t.string   "description", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "spreadsheet_submissions", force: :cascade do |t|
    t.integer  "spreadsheet_id",        limit: 4
    t.integer  "submission_progress",   limit: 4
    t.boolean  "successful_submission"
    t.text     "failure_message",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "spreadsheets", force: :cascade do |t|
    t.string   "filename",          limit: 255,                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "successful_upload",             default: false
  end

  add_index "spreadsheets", ["filename"], name: "index_spreadsheets_on_filename", unique: true, using: :btree

  create_table "titles", force: :cascade do |t|
    t.string   "title_text",         limit: 255
    t.text     "description",        limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "series_id",          limit: 8
    t.integer  "spreadsheet_id",     limit: 8
    t.integer  "series_title_index", limit: 4
  end

  create_table "units", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "abbreviation", limit: 255, null: false
    t.string   "institution",  limit: 255, null: false
    t.string   "campus",       limit: 255
    t.integer  "menu_index",   limit: 4
  end

  add_index "units", ["abbreviation"], name: "index_units_on_abbreviation", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "username",               limit: 255,                 null: false
    t.string   "first_name",             limit: 255,                 null: false
    t.string   "last_name",              limit: 255,                 null: false
    t.integer  "role_mask",              limit: 4,   default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",                             default: false
    t.string   "email_address",          limit: 255
    t.integer  "created_in_spreadsheet", limit: 8
  end

  create_trigger("physical_objects_after_update_of_iu_barcode_row_tr", :generated => true, :compatibility => 1).
      on("physical_objects").
      after(:update).
      of(:iu_barcode) do
    "INSERT INTO physical_object_old_barcodes(physical_object_id, iu_barcode) VALUES(OLD.id, OLD.iu_barcode);"
  end

end
