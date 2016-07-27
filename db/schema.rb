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

ActiveRecord::Schema.define(version: 20160727124650) do

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
    t.integer  "user_id",          limit: 8
    t.string   "location",         limit: 255
    t.integer  "collection_id",    limit: 8
    t.string   "media_type",       limit: 255
    t.integer  "iu_barcode",       limit: 8
    t.string   "title",            limit: 255, null: false
    t.integer  "copy_right",       limit: 4
    t.string   "format",           limit: 255
  end

  create_table "users", force: :cascade do |t|
    t.string   "username",   limit: 255,             null: false
    t.string   "first_name", limit: 255,             null: false
    t.string   "last_name",  limit: 255,             null: false
    t.integer  "role_mask",  limit: 4,   default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_trigger("physical_objects_after_update_of_iu_barcode_row_tr", :generated => true, :compatibility => 1).
      on("physical_objects").
      after(:update).
      of(:iu_barcode) do
    "INSERT INTO physical_object_old_barcodes(physical_object_id, iu_barcode) VALUES(OLD.id, OLD.iu_barcode);"
  end

end
