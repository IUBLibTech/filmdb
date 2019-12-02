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

ActiveRecord::Schema.define(version: 20191202171255) do

  create_table "boolean_conditions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint   "physical_object_id"
    t.string   "condition_type"
    t.text     "comment",            limit: 65535
    t.text     "fixed_comment",      limit: 65535
    t.bigint   "fixed_user_id"
    t.boolean  "active",                           default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cage_shelf_physical_objects", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint   "physical_object_id"
    t.bigint   "cage_shelf_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cage_shelves", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint   "cage_id"
    t.bigint   "mdpi_barcode"
    t.string   "identifier"
    t.text     "notes",         limit: 65535
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.boolean  "returned",                    default: false
    t.datetime "shipped"
    t.datetime "returned_date"
    t.index ["mdpi_barcode"], name: "index_cage_shelves_on_mdpi_barcode", unique: true, using: :btree
  end

  create_table "cages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "identifier"
    t.text     "notes",           limit: 65535
    t.bigint   "top_shelf_id"
    t.bigint   "middle_shelf_id"
    t.bigint   "bottom_shelf_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "ready_to_ship",                 default: false
    t.boolean  "shipped",                       default: false
  end

  create_table "collections", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint   "unit_id"
    t.text     "summary",    limit: 65535
  end

  create_table "component_group_physical_objects", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint   "component_group_id"
    t.bigint   "physical_object_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "scan_resolution"
    t.string   "clean"
    t.boolean  "hand_clean_only"
    t.boolean  "return_on_reel"
    t.string   "color_space"
  end

  create_table "component_groups", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint   "title_id",                                      null: false
    t.string   "group_type",                                    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "group_summary",   limit: 65535
    t.text     "scan_resolution", limit: 65535
    t.string   "clean",                         default: "Yes"
    t.boolean  "hand_clean_only",               default: false
    t.boolean  "hd"
    t.boolean  "return_on_reel",                default: false
    t.string   "color_space"
  end

  create_table "controlled_vocabularies", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "model_type"
    t.string   "model_attribute"
    t.string   "value"
    t.boolean  "default"
    t.integer  "menu_index",      default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active_status",   default: true
  end

  create_table "digiprovs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint   "physical_object_id"
    t.text     "digital_provenance_text", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint   "cage_shelf_id"
  end

  create_table "films", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
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
    t.string  "gauge"
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
    t.string  "reel_number"
    t.string  "can_size"
    t.integer "footage"
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
    t.string  "frame_rate"
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
    t.text    "sound",                                 limit: 65535
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
    t.boolean "sound_configuration_multi_track"
    t.boolean "sound_configuration_dual_mono"
    t.string  "ad_strip"
    t.decimal "shrinkage",                                           precision: 10
    t.string  "mold"
    t.text    "missing_footage",                       limit: 65535
    t.boolean "multiple_items_in_can"
    t.boolean "color_bw_color_color"
    t.boolean "color_bw_bw_black_and_white"
    t.boolean "color_bw_bw_hand_coloring"
    t.boolean "color_bw_bw_stencil_coloring"
    t.text    "captions_or_subtitles_notes",           limit: 65535
    t.boolean "sound_format_optical"
    t.string  "anamorphic"
    t.integer "track_count"
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
    t.string  "close_caption"
    t.text    "generation_notes",                      limit: 65535
  end

  create_table "languages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint   "physical_object_id"
    t.string   "language"
    t.string   "language_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "physical_object_dates", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint   "physical_object_id"
    t.bigint   "controlled_vocabulary_id"
    t.string   "date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "physical_object_old_barcodes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint   "physical_object_id"
    t.bigint   "iu_barcode"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["iu_barcode"], name: "index_physical_object_old_barcodes_on_iu_barcode", unique: true, using: :btree
  end

  create_table "physical_object_original_identifiers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint   "physical_object_id"
    t.string   "identifier",         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "physical_object_pull_requests", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint   "physical_object_id"
    t.bigint   "pull_request_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "physical_object_titles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint   "title_id"
    t.bigint   "physical_object_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["physical_object_id", "title_id"], name: "index_physical_object_titles_on_physical_object_id_and_title_id", unique: true, using: :btree
  end

  create_table "physical_objects", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "date_inventoried"
    t.bigint   "inventoried_by"
    t.string   "location"
    t.bigint   "collection_id"
    t.string   "media_type"
    t.bigint   "iu_barcode",                                                        null: false
    t.integer  "spreadsheet_id"
    t.string   "alternative_title"
    t.text     "accompanying_documentation",          limit: 65535
    t.text     "notes",                               limit: 65535
    t.bigint   "unit_id"
    t.string   "medium"
    t.bigint   "modified_by"
    t.string   "access"
    t.integer  "duration"
    t.text     "format_notes",                        limit: 65535
    t.string   "condition_rating"
    t.text     "condition_notes",                     limit: 65535
    t.string   "research_value"
    t.text     "research_value_notes",                limit: 65535
    t.text     "conservation_actions",                limit: 65535
    t.bigint   "mdpi_barcode"
    t.text     "accompanying_documentation_location", limit: 65535
    t.text     "miscellaneous",                       limit: 65535
    t.string   "title_control_number"
    t.bigint   "cage_shelf_id"
    t.bigint   "component_group_id"
    t.boolean  "in_freezer",                                        default: false
    t.boolean  "awaiting_freezer",                                  default: false
    t.string   "alf_shelf"
    t.string   "catalog_key"
    t.boolean  "digitized"
    t.bigint   "current_workflow_status_id"
    t.string   "compilation"
    t.integer  "actable_id"
    t.string   "actable_type"
    t.index ["actable_id", "actable_type"], name: "index_physical_objects_on_actable_id_and_actable_type", unique: true, using: :btree
    t.index ["current_workflow_status_id"], name: "index_physical_objects_on_current_workflow_status_id", using: :btree
    t.index ["iu_barcode", "mdpi_barcode"], name: "index_physical_objects_on_iu_barcode_and_mdpi_barcode", unique: true, using: :btree
  end

  create_table "pod_pushes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.text     "response",   limit: 4294967295
    t.bigint   "cage_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pull_requests", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint   "created_by_id"
    t.string   "filename"
    t.text     "file_contents", limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "series", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "title"
    t.string   "summary"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint   "created_by_id"
    t.bigint   "modified_by_id"
    t.string   "production_number"
    t.string   "date"
    t.integer  "total_episodes"
    t.bigint   "spreadsheet_id"
  end

  create_table "spreadsheet_submissions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "spreadsheet_id"
    t.integer  "submission_progress"
    t.boolean  "successful_submission"
    t.text     "failure_message",       limit: 4294967295
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "spreadsheets", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "filename",                          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "successful_upload", default: false
    t.index ["filename"], name: "index_spreadsheets_on_filename", unique: true, using: :btree
  end

  create_table "title_creators", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint   "title_id"
    t.string   "name"
    t.string   "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "title_dates", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint   "title_id"
    t.string   "date_text"
    t.string   "date_type"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
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

  create_table "title_forms", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint   "title_id"
    t.string   "form"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "title_genres", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint   "title_id"
    t.string   "genre"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "title_locations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint   "title_id"
    t.string   "location",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "title_original_identifiers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint   "title_id"
    t.string   "identifier"
    t.string   "identifier_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "title_publishers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint   "title_id"
    t.string   "name"
    t.string   "publisher_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "titles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "title_text",         limit: 1024
    t.text     "summary",            limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint   "series_id"
    t.bigint   "spreadsheet_id"
    t.integer  "series_title_index"
    t.bigint   "modified_by_id"
    t.string   "series_part"
    t.bigint   "created_by_id"
    t.text     "notes",              limit: 65535
    t.text     "subject",            limit: 65535
    t.text     "name_authority",     limit: 65535
    t.text     "country_of_origin",  limit: 65535
    t.boolean  "fully_cataloged"
  end

  create_table "units", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "abbreviation", null: false
    t.string   "institution",  null: false
    t.string   "campus"
    t.integer  "menu_index"
    t.index ["abbreviation"], name: "index_units_on_abbreviation", unique: true, using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "username",                                            null: false
    t.string   "first_name",                                          null: false
    t.string   "last_name",                                           null: false
    t.integer  "role_mask",                           default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",                              default: false
    t.string   "email_address"
    t.bigint   "created_in_spreadsheet"
    t.boolean  "can_delete",                          default: false
    t.string   "worksite_location"
    t.boolean  "works_in_both_locations",             default: false
    t.boolean  "can_update_physical_object_location", default: false
    t.boolean  "can_edit_users",                      default: false
    t.boolean  "can_add_cv",                          default: false
    t.boolean  "read_only"
  end

  create_table "value_conditions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint   "physical_object_id"
    t.string   "condition_type"
    t.string   "value"
    t.text     "comment",            limit: 65535
    t.text     "fixed_comment",      limit: 65535
    t.bigint   "fixed_user_id"
    t.boolean  "active",                           default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "videos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string  "gauge"
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
    t.string  "reel_number"
    t.string  "size"
    t.string  "recording_standard"
    t.string  "maximum_runtime"
    t.string  "base"
    t.string  "stock"
    t.boolean "picture_type_not_applicable"
    t.boolean "picture_type_silent_picture"
    t.boolean "picture_type_mos_picture"
    t.boolean "picture_type_composite_picture"
    t.boolean "picture_type_credits_only"
    t.boolean "picture_type_picture_effects"
    t.boolean "picture_type_picture_outtakes"
    t.boolean "picture_type_other"
    t.string  "playback_speed"
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
    t.string  "mold"
    t.text    "playback_issues_video_artifacts",           limit: 65535
    t.text    "playback_issues_audio_artifacts",           limit: 65535
    t.text    "missing_footage",                           limit: 65535
    t.text    "captions_or_subtitles_notes",               limit: 65535
    t.text    "generation_notes",                          limit: 65535
    t.string  "sound"
    t.string  "tape_capacity"
  end

  create_table "workflow_statuses", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint   "physical_object_id"
    t.string   "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "workflow_type"
    t.string   "whose_workflow"
    t.string   "status_name"
    t.integer  "component_group_id"
    t.integer  "external_entity_id"
    t.bigint   "created_by"
    t.index ["physical_object_id"], name: "index_workflow_statuses_on_physical_object_id", using: :btree
    t.index ["status_name"], name: "index_workflow_statuses_on_status_name", using: :btree
  end

  create_trigger("physical_objects_after_update_of_iu_barcode_row_tr", :generated => true, :compatibility => 1).
      on("physical_objects").
      after(:update).
      of(:iu_barcode) do
    "INSERT INTO physical_object_old_barcodes(physical_object_id, iu_barcode) VALUES(OLD.id, OLD.iu_barcode);"
  end

end
