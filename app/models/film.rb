class Film < ActiveRecord::Base
  acts_as :physical_object
  validates :gauge, presence: true

  VERSION_FIELDS = [:first_edition, :second_edition, :third_edition, :fourth_edition, :abridged, :short, :long, :sample,
                    :preview, :revised, :version_original, :captioned, :excerpt, :catholic, :domestic, :trailer, :english, :television, :x_rated]
  VERSION_FIELDS_HUMANIZED = {first_edition: "1st Edition", second_edition: "2nd Edition", third_edition: "3rd Edition", fourth_edition: "4th Edition", x_rated: "X-rated"}
  GENERATION_FIELDS = [
      :generation_negative, :generation_positive, :generation_reversal, :generation_projection_print, :generation_answer_print, :generation_work_print,
      :generation_composite, :generation_intermediate, :generation_mezzanine, :generation_kinescope, :generation_magnetic_track, :generation_optical_sound_track,
      :generation_outs_and_trims, :generation_a_roll, :generation_b_roll, :generation_c_roll, :generation_d_roll, :generation_edited,
      :generation_original_camera, :generation_original, :generation_fine_grain_master, :generation_separation_master, :generation_duplicate,
      :generation_master, :generation_other
  ]
  GENERATION_FIELDS_HUMANIZED = {
      generation_negative: "Negative", generation_positive: "Positive", generation_reversal: "Reversal", generation_projection_print: "Projection Print",
      generation_answer_print: "Answer Print", generation_work_print: "Work Print", generation_composite: "Composite", generation_intermediate: "Intermediate",
      generation_mezzanine: "Mezzanine", generation_kinescope: "Kinescope", generation_magnetic_track: "Separate Magnetic Track", generation_optical_sound_track: "Separate Optical Track",
      generation_outs_and_trims: "Outs and Trims", generation_a_roll: "A Roll", generation_b_roll: "B Roll", generation_c_roll: "C Roll", generation_d_roll: "D Roll",
      generation_edited: "Edited", generation_original_camera: "Camera Original", generation_original: "Original",
      generation_fine_grain_master: "Fine Grain Master", generation_separation_master: "Separation Master", generation_duplicate: "Duplicate", generation_master: 'Master',
      generation_other: "Other"
  }

  BASE_FIELDS =[:base_acetate, :base_polyester, :base_nitrate, :base_mixed]
  BASE_FIELDS_HUMANIZED = {
      base_acetate: "Acetate", base_polyester: "Polyester", base_nitrate: "Nitrate", base_mixed: "Mixed"
  }

  STOCK_FIELDS = [:stock_agfa, :stock_ansco, :stock_dupont, :stock_orwo, :stock_fuji, :stock_gevaert, :stock_kodak, :stock_ferrania, :stock_3_m,:stock_agfa_gevaert, :stock_pathe, :stock_unknown]
  STOCK_FIELDS_HUMANIZED = {
      stock_agfa: 'Agfa', stock_ansco: "Ansco", stock_dupont: 'Dupont', stock_orwo: "Orwo", stock_fuji: "Fuji", stock_gevaert: "Gevaert",
      stock_kodak: "Kodak", stock_ferrania: "Ferrania", stock_3_m: '3M', stock_agfa_gevaert: 'Agfa-Gevaert', stock_pathe: 'Pathe', stock_unknown: "Unknown"
  }

  PICTURE_TYPE_FIELDS = [
      :picture_not_applicable, :picture_silent_picture, :picture_mos_picture, :picture_composite_picture, :picture_intertitles_only,
      :picture_credits_only, :picture_picture_effects, :picture_picture_outtakes, :picture_kinescope, :picture_titles
  ]
  PICTURE_TYPE_FIELDS_HUMANIZED = {
      picture_not_applicable: "Not Applicable", picture_silent_picture: "Silent", picture_mos_picture: "MOS",
      picture_composite_picture: "Composite", picture_intertitles_only: "Intertitles Only", picture_credits_only: "Credits Only",
      picture_picture_effects: "Picture Effects", picture_picture_outtakes: "Outtakes", picture_kinescope: "Kinescope", picture_titles: 'Titles'
  }
  COLOR_BW_FIELDS = [
      :color_bw_bw_toned, :color_bw_bw_tinted, :color_bw_bw_hand_coloring, :color_bw_bw_stencil_coloring, :color_bw_bw_black_and_white
  ]
  COLOR_COLOR_FIELDS = [
      :color_bw_color_ektachrome, :color_bw_color_kodachrome, :color_bw_color_technicolor,
      :color_bw_color_anscochrome, :color_bw_color_eco, :color_bw_color_eastman, :color_bw_color_color
  ]
  COLOR_FIELDS = COLOR_BW_FIELDS + COLOR_COLOR_FIELDS

  COLOR_FIELDS_HUMANIZED = {
      color_bw_bw_toned: "Toned (Black and White)", color_bw_bw_tinted: "Tinted (Black and White)", color_bw_color_ektachrome: "Ektachrome",
      color_bw_color_kodachrome: "Kodachrome", color_bw_color_technicolor: "Technicolor", color_bw_color_anscochrome: "Anscochrome",
      color_bw_color_eco: "Eco", color_bw_color_eastman: "Eastman", color_bw_bw: "Black and White", color_bw_bw_hand_coloring: "Hand Coloring",
      color_bw_bw_stencil_coloring: "Stencil Coloring", color_bw_color_color: "Color", color_bw_bw_black_and_white: 'Black & White'
  }

  ASPECT_RATIO_FIELDS = [
      :aspect_ratio_1_33_1, :aspect_ratio_1_37_1, :aspect_ratio_1_66_1, :aspect_ratio_1_85_1, :aspect_ratio_2_35_1, :aspect_ratio_2_39_1, :aspect_ratio_2_59_1,
      :aspect_ratio_2_66_1, :aspect_ratio_1_36, :aspect_ratio_1_18
  ]
  ASPECT_RATIO_FIELDS_HUMANIZED = {
      aspect_ratio_1_33_1: "1.33:1", aspect_ratio_1_37_1: "1.37:1", aspect_ratio_1_66_1: "1.66:1", aspect_ratio_1_85_1: "1.85:1",
      aspect_ratio_2_35_1: "2.35:1", aspect_ratio_2_39_1: "2.39:1", aspect_ratio_2_59_1: "2.59:1", aspect_ratio_2_66_1: "2.66:1",
      aspect_ratio_1_36: '1.36:1', aspect_ratio_1_18: '1.18:1'
  }

  SOUND_FORMAT_FIELDS = [
      :sound_format_optical, :sound_format_optical_variable_area, :sound_format_optical_variable_density, :sound_format_magnetic,
      :sound_format_digital_sdds, :sound_format_digital_dts, :sound_format_digital_dolby_digital,
      :sound_format_sound_on_separate_media, :sound_format_digital_dolby_digital_sr, :sound_format_digital_dolby_digital_a
  ]
  SOUND_FORMAT_FIELDS_HUMANIZED = {
      sound_format_optical: 'Optical', sound_format_optical_variable_area: "Optical: Variable Area", sound_format_optical_variable_density: "Optical: Variable Density",
      sound_format_magnetic: "Magnetic", sound_format_digital_sdds: "Digital: SDDS", sound_format_digital_dts: "Digital: DTS", sound_format_digital_dolby_digital: "Digital: Dolby Digital",
      sound_format_sound_on_separate_media: "Sound on Separate Media", sound_format_digital_dolby_digital_sr: 'Digital: Dolby SR',
      sound_format_digital_dolby_digital_a: 'Digital: Dolby A'
  }

  SOUND_CONTENT_FIELDS = [:sound_content_music_track, :sound_content_effects_track, :sound_content_dialog, :sound_content_composite_track, :sound_content_outtakes, :sound_content_narration]
  SOUND_CONTENT_FIELDS_HUMANIZED = {
      sound_content_music_track: "Music Track", sound_content_effects_track: "Effects Track", sound_content_dialog: "Dialog",
      sound_content_composite_track: "Composite Track", sound_content_outtakes: "Outtakes", sound_content_narration: 'Narration'
  }

  SOUND_CONFIGURATION_FIELDS = [
      :sound_configuration_mono, :sound_configuration_stereo, :sound_configuration_surround, :sound_configuration_multi_track, :sound_configuration_dual_mono
  ]
  SOUND_CONFIGURATION_FIELDS_HUMANIZED = {
      sound_configuration_mono: "Mono", sound_configuration_stereo: "Stereo", sound_configuration_surround: "Surround",
      sound_configuration_multi_track: "Multi-track (ie. Maurer)", sound_configuration_dual_mono: "Dual Mono"
  }

  CONDITION_FIELDS_HUMANIZED = { ad_strip: "AD Strip" }

  # Merge all of the humanized field maps together so the search space is singular
  HUMANIZED_SYMBOLS = GENERATION_FIELDS_HUMANIZED.merge(VERSION_FIELDS_HUMANIZED.merge(BASE_FIELDS_HUMANIZED.merge(
      STOCK_FIELDS_HUMANIZED.merge(PICTURE_TYPE_FIELDS_HUMANIZED.merge(COLOR_FIELDS_HUMANIZED.merge(
          ASPECT_RATIO_FIELDS_HUMANIZED.merge(SOUND_FORMAT_FIELDS_HUMANIZED.merge(
              SOUND_CONTENT_FIELDS_HUMANIZED.merge(SOUND_CONFIGURATION_FIELDS_HUMANIZED.merge(CONDITION_FIELDS_HUMANIZED))
          ))))))))

  # overridden to provide for more human readable attribute names for things like :sample_rate_32k
  def self.human_attribute_name(attribute, options = {})
    self.const_get(:HUMANIZED_SYMBOLS)[attribute.to_sym] || super
  end

  def humanize_boolean_fields(field_names)
    str = ""
    field_names.each do |f|
      str << (self.specific[f] ? (str.length > 0 ? ", " << self.class.human_attribute_name(f) : self.class.human_attribute_name(f)) : "")
    end
    str
  end
end
