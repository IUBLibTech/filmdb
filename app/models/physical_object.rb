class PhysicalObject < ActiveRecord::Base
	include ActiveModel::Validations

	belongs_to :title
	has_many :physical_object_old_barcodes
	belongs_to :spreadhsheet
	belongs_to :collection
	belongs_to :unit
	belongs_to :inventorier, class_name: "User", foreign_key: "inventoried_by"
	belongs_to :modifier, class_name: "User", foreign_key: "modified_by"

	validates :title_id, presence: true
	validates :iu_barcode, iu_barcode: true
	validates :unit, presence: true
	validates :media_type, presence: true
	validates :medium, presence: true

	trigger.after(:update).of(:iu_barcode) do
		"INSERT INTO physical_object_old_barcodes(physical_object_id, iu_barcode) VALUES(OLD.id, OLD.iu_barcode)"
	end

	MEDIA_TYPES = ['Moving Image', 'Recorded Sound', 'Still Image', 'Text', 'Three Dimensional Object', 'Software', 'Mixed Material']
	MEDIA_TYPE_MEDIUMS = {
		'Moving Image' => ['Film', 'Video', 'Digital'],
		'Recorded Sound' => ['Recorded Sound'],
		'Still Image' => ['Still Image'],
		'Text' => ['Text'],
		'Three Dimensional Object' => ['Three Dimensional Object'],
		'Software' => ['Software'],
		'Mixed Media' => ['Mixed Media']
	}

  VERSION_FIELDS = [:first_edition, :second_edition, :third_edition, :fourth_edition, :abridged, :short, :long, :sample,
      :preview, :revised, :original, :captioned, :excerpt, :catolic, :domestic, :trailer, :english, :television, :x_rated]
  VERSION_FIELDS_HUMANIZED = {first_edition: "1st Edition", second_edition: "2nd Edition", third_edition: "3rd Edition", fourth_edition: "4th Edition", x_rated: "X-rated"}

  GENERATION_FIELDS = [
                    :generation_negative, :generation_positive, :generation_reversal, :generation_projection_print, :generation_answer_print, :generation_work_print,
                    :generation_composite, :generation_intermediate, :generation_mezzanine, :generation_kinescope, :generation_magnetic_track, :generation_optical_sound_track,
                    :generation_outs_and_trims, :generation_ab_a_roll, :generation_ab_b_roll, :generation_ab_c_roll, :generation_ab_d_roll, :generation_edited,
                    :generation_edited_camera_original, :generation_original, :generation_mixed, :generation_fine_grain_master, :generation_separation_master, :generation_duplicate
                    ]
  GENERATION_FIELDS_HUMANIZED = {
      generation_negative: "Negative", generation_positive: "Positive", generation_reversal: "Reversal", generation_projection_print: "Projection Print",
      generation_answer_print: "Answer Print", generation_work_print: "Work Print", generation_composite: "Composite", generation_intermediate: "Intermediate",
      generation_mezzanine: "Mezzanine", generation_kinescope: "Kinescope", generation_magnetic_track: "Magnetic Track", generation_optical_sound_track: "Optical Sound Track",
      generation_outs_and_trims: "Outs and Trims", generation_ab_a_roll: "A Roll", generation_ab_b_roll: "B Roll", generation_ab_c_roll: "C Roll", generation_ab_d_roll: "D Roll",
      generation_edited: "Edited", generation_edited_camera_original: "Edited Camera Original", generation_original: "Original", generation_mixed: "Mixed",
      generation_fine_grain_master: "Fine Grain Master", generation_separation_master: "Separation Master", generation_duplicate: "Duplicate"
  }

  BASE_FIELDS =[:base_acetate, :base_polyester, :base_nitrate, :base_mixed]
  BASE_FIELDS_HUMANIZED = {
    base_acetate: "Acetate", base_polyester: "Polyester", base_nitrate: "Nitrate", base_mixed: "Mixed"
  }

  STOCK_FIELDS = [:stock_agfa, :stock_ansco, :stock_dupont, :stock_orwo, :stock_fuji, :stock_gevaert, :stock_kodak, :stock_ferrania, :stock_mixed]
  STOCK_FIELDS_HUMANIZED = {
      stock_agfa: 'Agfa', stock_ansco: "Ansco", stock_dupont: 'Dupont', stock_orwo: "Orwo", stock_fuji: "Fuji", stock_gevaert: "Gevaert",
      stock_kodak: "Kodak", stock_ferrania: "Ferrania", stock_mixed: "Mixed"
  }

  PICTURE_TYPE_FIELDS = [
      :picture_not_applicable, :picture_silent_picture, :picture_mos_picture, :picture_composite_picture, :picture_intertitles_only,
      :picture_credits_only, :picture_picture_effects, :picture_picture_outtakes, :picture_picture_kinescope
  ]
  PICTURE_TYPE_FIELDS_HUMANIZED = {
      picture_not_applicable: "Not Applicable", picture_silent_picture: "Silent", picture_mos_picture: "MOS",
      picture_composite_picture: "Composite", picture_intertitles_only: "Intertitles Only", picture_credits_only: "Credits Only",
      picture_picture_effects: "Picture Effects", picture_picture_outtakes: "Outtakes", picture_picture_kinescope: "Kinescope"
  }

  COLOR_FIELDS = [
      :color_bw_bw_toned, :color_bw_bw_tinted, :color_bw_color_ektachrome, :color_bw_color_kodachrome, :color_bw_color_technicolor,
      :color_bw_color_anscochrome, :color_bw_color_eco, :color_bw_color_eastman, :color_bw_color_bw_mixed, :color_bw_color,
      :color_bw_bw
  ]
  COLOR_FIELDS_HUMANIZED = {
      color_bw_bw_toned: "Toned (Black and White)", color_bw_bw_tinted: "Tinted (Black and White)", color_bw_color_ektachrome: "Ektachrome",
      color_bw_color_kodachrome: "Kodachrome", color_bw_color_technicolor: "Technicolor", color_bw_color_anscochrome: "Ansochrome",
      color_bw_color_eco: "Eco", color_bw_color_eastman: "Eastman", color_bw_color_bw_mixed: "Mixed", color_bw_bw: "Black and White",
      color_bw_color: "Color"
  }

  ASPECT_RATIO_FIELDS = [
      :aspect_ratio_1_33_1, :aspect_ratio_1_37_1, :aspect_ratio_1_66_1, :aspect_ratio_1_85_1, :aspect_ratio_2_35_1, :aspect_ratio_2_39_1, :aspect_ratio_2_59_1
  ]
  ASPECT_RATIO_FIELDS_HUMANIZED = {
      aspect_ratio_1_33_1: "1:33:1", aspect_ratio_1_37_1: "1:37:1", aspect_ratio_1_66_1: "1:66:1", aspect_ratio_1_85_1: "1:85:1",
      aspect_ratio_2_35_1: "2:35:1", aspect_ratio_2_39_1: "2:39:1", aspect_ratio_2_59_1: "2:59:1"
  }

  SOUND_FORMAT_FIELDS = [
      :sound_format_optical_variable_area, :sound_format_optical_variable_density, :sound_format_magnetic,
      :sound_format_type_mixed, :sound_format_digital_sdds, :sound_format_digital_dts, :sound_format_digital_dolby_digital,
      :sound_format_sound_on_separate_media
  ]
  SOUND_FORMAT_FIELDS_HUMANIZED = {
      sound_format_optical_variable_area: "Variable Area (Optical)", sound_format_optical_variable_density: "Variable Density (Optical)",
      sound_format_magnetic: "Magnetic", sound_format_type_mixed: "Mixed", sound_format_digital_sdds: "SDDS (Digital)",
      sound_format_digital_dts: "DTS (Digital)", sound_format_digital_dolby_digital: "Dolby (Digital)",
      sound_format_sound_on_separate_media: "Sound on Separate Media"
  }

  SOUND_CONTENT_FIELDS = [:sound_content_music_track, :sound_content_effects_track, :sound_content_dialog, :sound_content_composite_track, :sound_content_outtakes]
  SOUND_CONTENT_FIELDS_HUMANIZED = {
      sound_content_music_track: "Music Track", sound_content_effects_track: "Effects Track", sound_content_dialog: "Dialog",
      sound_content_composite_track: "Composite Track", sound_content_outtakes: "Outtakes"
  }

  SOUND_CONFIGURATION_FIELDS = [
      :sound_configuration_mono, :sound_configuration_stereo, :sound_configuration_surround, :sound_configuration_multi_track, :sound_configuration_dual, :sound_configuration_single
  ]
  SOUND_CONFIGURATION_FIELDS_HUMANIZED = {
      sound_configuration_mono: "Mono", sound_configuration_stereo: "Stereo", sound_configuration_surround: "Surround",
      sound_configuration_multi_track: "Multi-track (Maurer", sound_configuration_dual: "Dual", sound_configuration_single: "Single"
  }

  LANGUAGE_FIELDS = [
      :language_arabic, :language_chinese, :language_english, :language_french, :language_german,
      :language_hindi, :language_italian, :language_japanese, :language_portuguese, :language_russian, :language_spanish
  ]
  LANGUAGE_FIELDS_HUMANIZED = {
      language_arabic: "Arabic", language_chinese: "Chinese", language_english: "English", language_french: "French",
      language_german: "German", language_hindi: "Hindi", language_italian: "Italian", language_japanese: "Japanese",
      language_portuguese: "Portuguese", language_russian: "Russian", language_spanish: "Spanish"
  }

  CONDITION_FIELDS = [
      :ad_strip, :shrinkage, :mold, :color_fade, :perforation_damage, :water_damage, :warp, :brittle,
      :splice_damage, :dirty, :peeling, :tape_residue, :broken, :tearing, :loose_wind, :not_on_core_or_reel,
      :missing_footage, :scratches
  ]
  CONDITION_FIELDS_HUMANIZED = { ad_strip: "AD Strip" }

  # Merge all of the humanized field maps together so the search space is singular
  HUMANIZED_SYMBOLS = GENERATION_FIELDS_HUMANIZED.merge(VERSION_FIELDS_HUMANIZED.merge(BASE_FIELDS_HUMANIZED.merge(
      STOCK_FIELDS_HUMANIZED.merge(PICTURE_TYPE_FIELDS_HUMANIZED.merge(COLOR_FIELDS_HUMANIZED.merge(
          ASPECT_RATIO_FIELDS_HUMANIZED.merge(SOUND_FORMAT_FIELDS_HUMANIZED.merge(
              SOUND_CONTENT_FIELDS_HUMANIZED.merge(SOUND_CONFIGURATION_FIELDS_HUMANIZED.merge(
                  LANGUAGE_FIELDS_HUMANIZED.merge(CONDITION_FIELDS_HUMANIZED))
              )))))))))

	def media_types
		MEDIA_TYPES
	end

	def media_type_mediums
		MEDAI_TYPE_MEDIUMS
	end

	# title_text, series_title_text, and collection_text are all necesasary for javascript autocomplete on these fields for
	# forms. They provide a display value for the title/series/collection but are never set directly - the id of the model record
	# is set and passed as the param for assignment
	def title_text
		self.title.title_text if self.title
	end

	def series_title_text
		self.title.series.title if self.title && self.title.series
	end

	def series_id
		self.title.series.id if self.title && self.title.series
	end

	def collection_text
		self.collection.name if self.collection
	end

	# duration is input as hh:mm:ss
	def duration=(time)
		super(time.split(':').map { |a| a.to_i }.inject(0) { |a, b| a * 60 + b})
  end

  # duration is viewed as hh:mm:ss
  def duration
    unless super.nil?
      hh = (super / 3600).floor
      mm = ((super - (hh * 3600)) / 60).floor
      ss = super - (hh * 3600) - (mm * 60)
      "#{hh}:#{mm}:#{ss}"
    end
  end

  # overridden to provide for more human readable attribute names for things like :sample_rate_32k
  def self.human_attribute_name(attribute, options = {})
    self.const_get(:HUMANIZED_SYMBOLS)[attribute.to_sym] || super
  end

  def humanize_boolean_fields(field_names)
    str = ""
    field_names.each do |f|
      str << (self[f] ? (str.length > 0 ? ", " << self.class.human_attribute_name(f) : self.class.human_attribute_name(f)) : "")
    end
    str
  end

end
