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

ActiveRecord::Schema.define(version: 20210113172716) do

  create_table "ar_internal_metadata", primary_key: "key", force: :cascade do |t|
    t.string   "value",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "boolean_conditions", force: :cascade do |t|
    t.integer  "physical_object_id", limit: 8
    t.string   "condition_type",     limit: 255
    t.text     "comment",            limit: 65535
    t.text     "fixed_comment",      limit: 65535
    t.integer  "fixed_user_id",      limit: 8
    t.boolean  "active",                           default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cage_shelf_physical_objects", force: :cascade do |t|
    t.integer  "physical_object_id", limit: 8
    t.integer  "cage_shelf_id",      limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cage_shelves", force: :cascade do |t|
    t.integer  "cage_id",       limit: 8
    t.integer  "mdpi_barcode",  limit: 8
    t.string   "identifier",    limit: 255
    t.text     "notes",         limit: 65535
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.boolean  "returned",                    default: false
    t.datetime "shipped"
    t.datetime "returned_date"
  end

  add_index "cage_shelves", ["mdpi_barcode"], name: "index_cage_shelves_on_mdpi_barcode", unique: true, using: :btree

  create_table "cages", force: :cascade do |t|
    t.string   "identifier",      limit: 255
    t.text     "notes",           limit: 65535
    t.integer  "top_shelf_id",    limit: 8
    t.integer  "middle_shelf_id", limit: 8
    t.integer  "bottom_shelf_id", limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "ready_to_ship",                 default: false
    t.boolean  "shipped",                       default: false
  end

  create_table "collections", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "unit_id",    limit: 8
    t.text     "summary",    limit: 65535
  end

  create_table "component_group_physical_objects", force: :cascade do |t|
    t.integer  "component_group_id", limit: 8
    t.integer  "physical_object_id", limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "scan_resolution",    limit: 255
    t.string   "clean",              limit: 255
    t.boolean  "hand_clean_only"
    t.boolean  "return_on_reel"
    t.string   "color_space",        limit: 255
  end

  create_table "component_groups", force: :cascade do |t|
    t.integer  "title_id",        limit: 8,                     null: false
    t.string   "group_type",      limit: 255,                   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "group_summary",   limit: 65535
    t.text     "scan_resolution", limit: 65535
    t.string   "clean",           limit: 255,   default: "Yes"
    t.boolean  "hand_clean_only",               default: false
    t.boolean  "hd"
    t.boolean  "return_on_reel",                default: false
    t.string   "color_space",     limit: 255
  end

  create_table "controlled_vocabularies", force: :cascade do |t|
    t.string   "model_type",      limit: 255
    t.string   "model_attribute", limit: 255
    t.string   "value",           limit: 255
    t.boolean  "default"
    t.integer  "menu_index",      limit: 4,   default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active_status",               default: true
  end

  create_table "delete_log_entries", force: :cascade do |t|
    t.integer  "table_id",                  limit: 4
    t.string   "object_type",               limit: 255
    t.string   "human_readable_identifier", limit: 255
    t.string   "who_deleted",               limit: 255
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  create_table "digiprovs", force: :cascade do |t|
    t.integer  "physical_object_id",      limit: 8
    t.text     "digital_provenance_text", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cage_shelf_id",           limit: 8
  end

  create_table "films", force: :cascade do |t|
    t.boolean "first_edition"
    t.boolean "second_edition"
    t.boolean "third_edition"
    t.boolean "fourth_edition"
    t.boolean "abridged"
    t.boolean "short"
    t.boolean "long"
    t.boolean "sample"
    t.boolean "preview"
    t.boolean "revised"
    t.boolean "version_original"
    t.boolean "captioned"
    t.boolean "excerpt"
    t.boolean "catholic"
    t.boolean "domestic"
    t.boolean "trailer"
    t.boolean "english"
    t.boolean "television"
    t.boolean "x_rated"
    t.string  "gauge",                                                  limit: 255
    t.boolean "generation_projection_print"
    t.boolean "generation_a_roll"
    t.boolean "generation_b_roll"
    t.boolean "generation_c_roll"
    t.boolean "generation_d_roll"
    t.boolean "generation_answer_print"
    t.boolean "generation_composite"
    t.boolean "generation_duplicate"
    t.boolean "generation_edited"
    t.boolean "generation_fine_grain_master"
    t.boolean "generation_intermediate"
    t.boolean "generation_kinescope"
    t.boolean "generation_magnetic_track"
    t.boolean "generation_mezzanine"
    t.boolean "generation_negative"
    t.boolean "generation_optical_sound_track"
    t.boolean "generation_original"
    t.boolean "generation_outs_and_trims"
    t.boolean "generation_positive"
    t.boolean "generation_reversal"
    t.boolean "generation_separation_master"
    t.boolean "generation_work_print"
    t.boolean "generation_mixed"
    t.string  "reel_number",                                            limit: 255
    t.string  "can_size",                                               limit: 255
    t.integer "footage",                                                limit: 4
    t.boolean "base_acetate"
    t.boolean "base_polyester"
    t.boolean "base_nitrate"
    t.boolean "base_mixed"
    t.boolean "stock_agfa"
    t.boolean "stock_ansco"
    t.boolean "stock_dupont"
    t.boolean "stock_orwo"
    t.boolean "stock_fuji"
    t.boolean "stock_gevaert"
    t.boolean "stock_kodak"
    t.boolean "stock_ferrania"
    t.boolean "picture_not_applicable"
    t.boolean "picture_silent_picture"
    t.boolean "picture_mos_picture"
    t.boolean "picture_composite_picture"
    t.boolean "picture_intertitles_only"
    t.boolean "picture_credits_only"
    t.boolean "picture_picture_effects"
    t.boolean "picture_picture_outtakes"
    t.boolean "picture_kinescope"
    t.string  "frame_rate",                                             limit: 255
    t.boolean "color_bw_bw_toned"
    t.boolean "color_bw_bw_tinted"
    t.boolean "color_bw_color_ektachrome"
    t.boolean "color_bw_color_kodachrome"
    t.boolean "color_bw_color_technicolor"
    t.boolean "color_bw_color_anscochrome"
    t.boolean "color_bw_color_eco"
    t.boolean "color_bw_color_eastman"
    t.boolean "aspect_ratio_1_33_1"
    t.boolean "aspect_ratio_1_37_1"
    t.boolean "aspect_ratio_1_66_1"
    t.boolean "aspect_ratio_1_85_1"
    t.boolean "aspect_ratio_2_35_1"
    t.boolean "aspect_ratio_2_39_1"
    t.boolean "aspect_ratio_2_59_1"
    t.text    "sound",                                                  limit: 65535
    t.boolean "sound_format_optical_variable_area"
    t.boolean "sound_format_optical_variable_density"
    t.boolean "sound_format_magnetic"
    t.boolean "sound_format_digital_sdds"
    t.boolean "sound_format_digital_dts"
    t.boolean "sound_format_digital_dolby_digital"
    t.boolean "sound_format_sound_on_separate_media"
    t.boolean "sound_content_music_track"
    t.boolean "sound_content_effects_track"
    t.boolean "sound_content_dialog"
    t.boolean "sound_content_composite_track"
    t.boolean "sound_content_outtakes"
    t.boolean "sound_configuration_mono"
    t.boolean "sound_configuration_stereo"
    t.boolean "sound_configuration_surround"
    t.boolean "sound_format_optical_variable_area_maurer"
    t.boolean "sound_configuration_dual_mono"
    t.string  "ad_strip",                                               limit: 255
    t.float   "shrinkage",                                              limit: 24
    t.string  "mold",                                                   limit: 255
    t.text    "missing_footage",                                        limit: 65535
    t.boolean "multiple_items_in_can"
    t.boolean "color_bw_color_color"
    t.boolean "color_bw_bw_black_and_white"
    t.boolean "color_bw_bw_hand_coloring"
    t.boolean "color_bw_bw_stencil_coloring"
    t.text    "captions_or_subtitles_notes",                            limit: 65535
    t.boolean "sound_format_optical"
    t.string  "anamorphic",                                             limit: 255
    t.integer "track_count",                                            limit: 4
    t.boolean "generation_original_camera"
    t.boolean "generation_master"
    t.boolean "sound_format_digital_dolby_digital_sr"
    t.boolean "sound_format_digital_dolby_digital_a"
    t.boolean "stock_3_m"
    t.boolean "stock_agfa_gevaert"
    t.boolean "stock_pathe"
    t.boolean "stock_unknown"
    t.boolean "aspect_ratio_2_66_1"
    t.boolean "aspect_ratio_1_36"
    t.boolean "aspect_ratio_1_18"
    t.boolean "picture_titles"
    t.boolean "generation_other"
    t.boolean "sound_content_narration"
    t.string  "close_caption",                                          limit: 255
    t.text    "generation_notes",                                       limit: 65535
    t.boolean "generation_interpositive"
    t.boolean "picture_text"
    t.boolean "aspect_ratio_2_55_1"
    t.boolean "sound_format_optical_variable_area_bilateral"
    t.boolean "sound_format_optical_variable_area_dual_bilateral"
    t.boolean "sound_format_optical_variable_area_unilateral"
    t.boolean "sound_format_optical_variable_area_dual_unilateral"
    t.boolean "sound_format_optical_variable_area_rca_duplex"
    t.boolean "sound_format_optical_variable_density_multiple_density"
  end

  create_table "languages", force: :cascade do |t|
    t.integer  "physical_object_id", limit: 8
    t.string   "language",           limit: 255
    t.string   "language_type",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "modifications", force: :cascade do |t|
    t.string   "object_type", limit: 255
    t.integer  "object_id",   limit: 4
    t.integer  "user_id",     limit: 8
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "physical_object_dates", force: :cascade do |t|
    t.integer  "physical_object_id",       limit: 8
    t.integer  "controlled_vocabulary_id", limit: 8
    t.string   "date",                     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "physical_object_old_barcodes", force: :cascade do |t|
    t.integer  "physical_object_id", limit: 8
    t.integer  "iu_barcode",         limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "physical_object_original_identifiers", force: :cascade do |t|
    t.integer  "physical_object_id", limit: 8
    t.string   "identifier",         limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "physical_object_pull_requests", force: :cascade do |t|
    t.integer  "physical_object_id", limit: 8
    t.integer  "pull_request_id",    limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "physical_object_titles", force: :cascade do |t|
    t.integer  "title_id",           limit: 8
    t.integer  "physical_object_id", limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "physical_object_titles", ["physical_object_id", "title_id"], name: "index_physical_object_titles_on_physical_object_id_and_title_id", unique: true, using: :btree

  create_table "physical_objects", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "date_inventoried"
    t.integer  "inventoried_by",                      limit: 8
    t.string   "location",                            limit: 255
    t.integer  "collection_id",                       limit: 8
    t.string   "media_type",                          limit: 255
    t.integer  "iu_barcode",                          limit: 8,                     null: false
    t.integer  "spreadsheet_id",                      limit: 4
    t.string   "alternative_title",                   limit: 255
    t.text     "accompanying_documentation",          limit: 65535
    t.text     "notes",                               limit: 65535
    t.integer  "unit_id",                             limit: 8
    t.string   "medium",                              limit: 255
    t.integer  "modified_by",                         limit: 8
    t.string   "access",                              limit: 255
    t.integer  "duration",                            limit: 4
    t.text     "format_notes",                        limit: 65535
    t.string   "condition_rating",                    limit: 255
    t.text     "condition_notes",                     limit: 65535
    t.string   "research_value",                      limit: 255
    t.text     "research_value_notes",                limit: 65535
    t.text     "conservation_actions",                limit: 65535
    t.integer  "mdpi_barcode",                        limit: 8
    t.text     "accompanying_documentation_location", limit: 65535
    t.text     "miscellaneous",                       limit: 65535
    t.string   "title_control_number",                limit: 255
    t.integer  "cage_shelf_id",                       limit: 8
    t.integer  "component_group_id",                  limit: 8
    t.boolean  "in_freezer",                                        default: false
    t.boolean  "awaiting_freezer",                                  default: false
    t.string   "alf_shelf",                           limit: 255
    t.string   "catalog_key",                         limit: 255
    t.boolean  "digitized"
    t.integer  "current_workflow_status_id",          limit: 8
    t.string   "compilation",                         limit: 255
    t.integer  "actable_id",                          limit: 4
    t.string   "actable_type",                        limit: 255
  end

  add_index "physical_objects", ["actable_id", "actable_type"], name: "index_physical_objects_on_actable_id_and_actable_type", unique: true, using: :btree
  add_index "physical_objects", ["current_workflow_status_id"], name: "index_physical_objects_on_current_workflow_status_id", using: :btree
  add_index "physical_objects", ["iu_barcode", "mdpi_barcode"], name: "index_physical_objects_on_iu_barcode_and_mdpi_barcode", unique: true, using: :btree

  create_table "pod_pushes", force: :cascade do |t|
    t.text     "response",   limit: 4294967295
    t.integer  "cage_id",    limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pull_requests", force: :cascade do |t|
    t.integer  "created_by_id", limit: 8
    t.string   "filename",      limit: 255
    t.text     "file_contents", limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recorded_sounds", force: :cascade do |t|
    t.boolean  "version_first_edition"
    t.boolean  "version_second_edition"
    t.boolean  "version_third_edition"
    t.boolean  "version_fourth_edition"
    t.boolean  "version_abridged"
    t.boolean  "version_anniversary"
    t.boolean  "version_domestic"
    t.boolean  "version_english"
    t.boolean  "version_excerpt"
    t.boolean  "version_long"
    t.boolean  "version_original"
    t.boolean  "version_reissue"
    t.boolean  "version_revised"
    t.boolean  "version_sample"
    t.boolean  "version_short"
    t.boolean  "version_x_rated"
    t.string   "gauge",                              limit: 255
    t.boolean  "generation_copy_access"
    t.boolean  "generation_dub"
    t.boolean  "generation_duplicate"
    t.boolean  "generation_intermediate"
    t.boolean  "generation_master"
    t.boolean  "generation_master_distribution"
    t.boolean  "generation_master_production"
    t.boolean  "generation_off_air_recording"
    t.boolean  "generation_original_recording"
    t.boolean  "generation_preservation"
    t.boolean  "generation_work_tapes"
    t.boolean  "generation_other"
    t.string   "sides",                              limit: 255
    t.string   "part",                               limit: 255
    t.string   "size",                               limit: 255
    t.string   "base",                               limit: 255
    t.string   "stock",                              limit: 255
    t.text     "detailed_stock_information",         limit: 65535
    t.boolean  "multiple_items_in_can"
    t.string   "playback",                           limit: 255
    t.boolean  "sound_content_type_composite_track"
    t.boolean  "sound_content_type_dialog"
    t.boolean  "sound_content_type_effects_track"
    t.boolean  "sound_content_type_music_track"
    t.boolean  "sound_content_type_outtakes"
    t.boolean  "sound_configuration_dual_mono"
    t.boolean  "sound_configuration_mono"
    t.boolean  "sound_configuration_stereo"
    t.boolean  "sound_configuration_surround"
    t.boolean  "sound_configuration_unknown"
    t.boolean  "sound_configuration_other"
    t.string   "mold",                               limit: 255
    t.integer  "actable_id",                         limit: 4
    t.string   "actable_type",                       limit: 255
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.string   "noise_reduction",                    limit: 255
    t.string   "capacity",                           limit: 255
    t.text     "generation_notes",                   limit: 65535
  end

  create_table "series", force: :cascade do |t|
    t.string   "title",             limit: 255
    t.string   "summary",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id",     limit: 8
    t.integer  "modified_by_id",    limit: 8
    t.string   "production_number", limit: 255
    t.string   "date",              limit: 255
    t.integer  "total_episodes",    limit: 4
    t.integer  "spreadsheet_id",    limit: 8
  end

  create_table "spreadsheet_submissions", force: :cascade do |t|
    t.integer  "spreadsheet_id",        limit: 4
    t.integer  "submission_progress",   limit: 4
    t.boolean  "successful_submission"
    t.text     "failure_message",       limit: 4294967295
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

  create_table "title_creators", force: :cascade do |t|
    t.integer  "title_id",   limit: 8
    t.string   "name",       limit: 255
    t.string   "role",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "title_dates", force: :cascade do |t|
    t.integer  "title_id",                    limit: 8
    t.string   "date_text",                   limit: 255
    t.string   "date_type",                   limit: 255
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.date     "start_date"
    t.boolean  "start_month_present"
    t.boolean  "start_day_present"
    t.boolean  "extra_text"
    t.boolean  "start_date_is_approximation"
    t.date     "end_date"
    t.boolean  "end_date_month_present"
    t.boolean  "end_date_day_present"
    t.boolean  "end_date_is_approximation"
  end

  create_table "title_forms", force: :cascade do |t|
    t.integer  "title_id",   limit: 8
    t.string   "form",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "title_genres", force: :cascade do |t|
    t.integer  "title_id",   limit: 8
    t.string   "genre",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "title_locations", force: :cascade do |t|
    t.integer  "title_id",   limit: 8
    t.string   "location",   limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "title_original_identifiers", force: :cascade do |t|
    t.integer  "title_id",        limit: 8
    t.string   "identifier",      limit: 255
    t.string   "identifier_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "title_publishers", force: :cascade do |t|
    t.integer  "title_id",       limit: 8
    t.string   "name",           limit: 255
    t.string   "publisher_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "titles", force: :cascade do |t|
    t.string   "title_text",               limit: 1024
    t.text     "summary",                  limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "series_id",                limit: 8
    t.integer  "spreadsheet_id",           limit: 8
    t.integer  "series_title_index",       limit: 4
    t.integer  "modified_by_id",           limit: 8
    t.string   "series_part",              limit: 255
    t.integer  "created_by_id",            limit: 8
    t.text     "notes",                    limit: 65535
    t.text     "subject",                  limit: 65535
    t.text     "name_authority",           limit: 65535
    t.text     "country_of_origin",        limit: 65535
    t.boolean  "fully_cataloged"
    t.string   "pod_group_key_identifier", limit: 255
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
    t.string   "username",                            limit: 255,                 null: false
    t.string   "first_name",                          limit: 255,                 null: false
    t.string   "last_name",                           limit: 255,                 null: false
    t.integer  "role_mask",                           limit: 4,   default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",                                          default: false
    t.string   "email_address",                       limit: 255
    t.integer  "created_in_spreadsheet",              limit: 8
    t.boolean  "can_delete",                                      default: false
    t.string   "worksite_location",                   limit: 255
    t.boolean  "works_in_both_locations",                         default: false
    t.boolean  "can_update_physical_object_location",             default: false
    t.boolean  "can_edit_users",                                  default: false
    t.boolean  "can_add_cv",                                      default: false
    t.boolean  "read_only"
  end

  create_table "value_conditions", force: :cascade do |t|
    t.integer  "physical_object_id", limit: 8
    t.string   "condition_type",     limit: 255
    t.string   "value",              limit: 255
    t.text     "comment",            limit: 65535
    t.text     "fixed_comment",      limit: 65535
    t.integer  "fixed_user_id",      limit: 8
    t.boolean  "active",                           default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "videos", force: :cascade do |t|
    t.string  "gauge",                                     limit: 255
    t.boolean "first_edition"
    t.boolean "second_edition"
    t.boolean "third_edition"
    t.boolean "fourth_edition"
    t.boolean "abridged"
    t.boolean "short"
    t.boolean "long"
    t.boolean "sample"
    t.boolean "revised"
    t.boolean "original"
    t.boolean "excerpt"
    t.boolean "catholic"
    t.boolean "domestic"
    t.boolean "trailer"
    t.boolean "english"
    t.boolean "non_english"
    t.boolean "television"
    t.boolean "x_rated"
    t.boolean "generation_b_roll"
    t.boolean "generation_commercial_release"
    t.boolean "generation_copy_access"
    t.boolean "generation_dub"
    t.boolean "generation_duplicate"
    t.boolean "generation_edited"
    t.boolean "generation_fine_cut"
    t.boolean "generation_intermediate"
    t.boolean "generation_line_cut"
    t.boolean "generation_master"
    t.boolean "generation_master_production"
    t.boolean "generation_master_distribution"
    t.boolean "generation_off_air_recording"
    t.boolean "generation_original"
    t.boolean "generation_picture_lock"
    t.boolean "generation_rough_cut"
    t.boolean "generation_stock_footage"
    t.boolean "generation_submaster"
    t.boolean "generation_work_tapes"
    t.boolean "generation_work_track"
    t.boolean "generation_other"
    t.string  "reel_number",                               limit: 255
    t.string  "size",                                      limit: 255
    t.string  "recording_standard",                        limit: 255
    t.string  "maximum_runtime",                           limit: 255
    t.string  "base",                                      limit: 255
    t.string  "stock",                                     limit: 255
    t.boolean "picture_type_not_applicable"
    t.boolean "picture_type_silent_picture"
    t.boolean "picture_type_mos_picture"
    t.boolean "picture_type_composite_picture"
    t.boolean "picture_type_credits_only"
    t.boolean "picture_type_picture_effects"
    t.boolean "picture_type_picture_outtakes"
    t.boolean "picture_type_other"
    t.string  "playback_speed",                            limit: 255
    t.boolean "image_color_bw"
    t.boolean "image_color_color"
    t.boolean "image_color_mixed"
    t.boolean "image_color_other"
    t.boolean "image_aspect_ratio_4_3"
    t.boolean "image_aspect_ratio_16_9"
    t.boolean "image_aspect_ratio_other"
    t.boolean "captions_or_subtitles"
    t.text    "notes",                                     limit: 65535
    t.boolean "silent"
    t.boolean "sound_format_type_magnetic"
    t.boolean "sound_format_type_digital"
    t.boolean "sound_format_type_sound_on_separate_media"
    t.boolean "sound_format_type_other"
    t.boolean "sound_content_type_music_track"
    t.boolean "sound_content_type_effects_track"
    t.boolean "sound_content_type_dialog"
    t.boolean "sound_content_type_composite_track"
    t.boolean "sound_content_type_outtakes"
    t.boolean "sound_configuration_mono"
    t.boolean "sound_configuration_stereo"
    t.boolean "sound_configuration_surround"
    t.boolean "sound_configuration_other"
    t.boolean "sound_noise_redux_dolby_a"
    t.boolean "sound_noise_redux_dolby_b"
    t.boolean "sound_noise_redux_dolby_c"
    t.boolean "sound_noise_redux_dolby_s"
    t.boolean "sound_noise_redux_dolby_sr"
    t.boolean "sound_noise_redux_dolby_nr"
    t.boolean "sound_noise_redux_dolby_hx"
    t.boolean "sound_noise_redux_dolby_hx_pro"
    t.boolean "sound_noise_redux_dbx"
    t.boolean "sound_noise_redux_dbx_type_1"
    t.boolean "sound_noise_redux_dbx_type_2"
    t.boolean "sound_noise_redux_high_com"
    t.boolean "sound_noise_redux_high_com_2"
    t.boolean "sound_noise_redux_adres"
    t.boolean "sound_noise_redux_anrs"
    t.boolean "sound_noise_redux_dnl"
    t.boolean "sound_noise_redux_dnr"
    t.boolean "sound_noise_redux_cedar"
    t.boolean "sound_noise_redux_none"
    t.string  "mold",                                      limit: 255
    t.text    "playback_issues_video_artifacts",           limit: 65535
    t.text    "playback_issues_audio_artifacts",           limit: 65535
    t.text    "missing_footage",                           limit: 65535
    t.text    "captions_or_subtitles_notes",               limit: 65535
    t.text    "generation_notes",                          limit: 65535
    t.string  "sound",                                     limit: 255
    t.integer "tape_capacity",                             limit: 4
    t.text    "detailed_stock_information",                limit: 65535
  end

  create_table "workflow_statuses", force: :cascade do |t|
    t.integer  "physical_object_id", limit: 8
    t.string   "notes",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "workflow_type",      limit: 255
    t.string   "whose_workflow",     limit: 255
    t.string   "status_name",        limit: 255
    t.integer  "component_group_id", limit: 4
    t.integer  "external_entity_id", limit: 4
    t.integer  "created_by",         limit: 8
  end

  add_index "workflow_statuses", ["physical_object_id"], name: "index_workflow_statuses_on_physical_object_id", using: :btree
  add_index "workflow_statuses", ["status_name"], name: "index_workflow_statuses_on_status_name", using: :btree

  create_trigger("physical_objects_after_update_of_iu_barcode_row_tr", :generated => true, :compatibility => 1).
      on("physical_objects").
      after(:update).
      of(:iu_barcode) do
    "INSERT INTO physical_object_old_barcodes(physical_object_id, iu_barcode) VALUES(OLD.id, OLD.iu_barcode);"
  end

end
