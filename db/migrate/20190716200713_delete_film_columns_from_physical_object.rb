class DeleteFilmColumnsFromPhysicalObject < ActiveRecord::Migration
  def change
    # remove old, a_unused columns - these attributes have been moved into film objects
    remove_column :physical_objects, :copy_right
    remove_column :physical_objects, :series_production_number
    remove_column :physical_objects, :series_part
    remove_column :physical_objects, :creator
    remove_column :physical_objects, :first_edition
    remove_column :physical_objects, :second_edition
    remove_column :physical_objects, :third_edition
    remove_column :physical_objects, :fourth_edition
    remove_column :physical_objects, :abridged
    remove_column :physical_objects, :short
    remove_column :physical_objects, :long
    remove_column :physical_objects, :sample
    remove_column :physical_objects, :preview
    remove_column :physical_objects, :revised
    remove_column :physical_objects, :version_original
    remove_column :physical_objects, :captioned
    remove_column :physical_objects, :excerpt
    remove_column :physical_objects, :catholic
    remove_column :physical_objects, :domestic
    remove_column :physical_objects, :trailer
    remove_column :physical_objects, :english
    remove_column :physical_objects, :television
    remove_column :physical_objects, :x_rated
    remove_column :physical_objects, :gauge
    remove_column :physical_objects, :generation_projection_print
    remove_column :physical_objects, :generation_a_roll
    remove_column :physical_objects, :generation_b_roll
    remove_column :physical_objects, :generation_c_roll
    remove_column :physical_objects, :generation_d_roll
    remove_column :physical_objects, :generation_answer_print
    remove_column :physical_objects, :generation_composite
    remove_column :physical_objects, :generation_duplicate
    remove_column :physical_objects, :generation_edited
    remove_column :physical_objects, :generation_fine_grain_master
    remove_column :physical_objects, :generation_intermediate
    remove_column :physical_objects, :generation_kinescope
    remove_column :physical_objects, :generation_magnetic_track
    remove_column :physical_objects, :generation_mezzanine
    remove_column :physical_objects, :generation_negative
    remove_column :physical_objects, :generation_optical_sound_track
    remove_column :physical_objects, :generation_original
    remove_column :physical_objects, :generation_outs_and_trims
    remove_column :physical_objects, :generation_positive
    remove_column :physical_objects, :generation_reversal
    remove_column :physical_objects, :generation_separation_master
    remove_column :physical_objects, :generation_work_print
    remove_column :physical_objects, :generation_mixed
    remove_column :physical_objects, :reel_number
    remove_column :physical_objects, :can_size
    remove_column :physical_objects, :footage
    remove_column :physical_objects, :base_acetate
    remove_column :physical_objects, :base_polyester
    remove_column :physical_objects, :base_nitrate
    remove_column :physical_objects, :base_mixed
    remove_column :physical_objects, :stock_agfa
    remove_column :physical_objects, :stock_ansco
    remove_column :physical_objects, :stock_dupont
    remove_column :physical_objects, :stock_orwo
    remove_column :physical_objects, :stock_fuji
    remove_column :physical_objects, :stock_gevaert
    remove_column :physical_objects, :stock_kodak
    remove_column :physical_objects, :stock_ferrania
    remove_column :physical_objects, :picture_not_applicable
    remove_column :physical_objects, :picture_silent_picture
    remove_column :physical_objects, :picture_mos_picture
    remove_column :physical_objects, :picture_composite_picture
    remove_column :physical_objects, :picture_intertitles_only
    remove_column :physical_objects, :picture_credits_only
    remove_column :physical_objects, :picture_picture_effects
    remove_column :physical_objects, :picture_picture_outtakes
    remove_column :physical_objects, :picture_kinescope
    remove_column :physical_objects, :frame_rate
    remove_column :physical_objects, :color_bw_bw_toned
    remove_column :physical_objects, :color_bw_bw_tinted
    remove_column :physical_objects, :color_bw_color_ektachrome
    remove_column :physical_objects, :color_bw_color_kodachrome
    remove_column :physical_objects, :color_bw_color_technicolor
    remove_column :physical_objects, :color_bw_color_anscochrome
    remove_column :physical_objects, :color_bw_color_eco
    remove_column :physical_objects, :color_bw_color_eastman
    remove_column :physical_objects, :aspect_ratio_1_33_1
    remove_column :physical_objects, :aspect_ratio_1_37_1
    remove_column :physical_objects, :aspect_ratio_1_66_1
    remove_column :physical_objects, :aspect_ratio_1_85_1
    remove_column :physical_objects, :aspect_ratio_2_35_1
    remove_column :physical_objects, :aspect_ratio_2_39_1
    remove_column :physical_objects, :aspect_ratio_2_59_1
    remove_column :physical_objects, :sound
    remove_column :physical_objects, :sound_format_optical_variable_area
    remove_column :physical_objects, :sound_format_optical_variable_density
    remove_column :physical_objects, :sound_format_magnetic
    remove_column :physical_objects, :sound_format_digital_sdds
    remove_column :physical_objects, :sound_format_digital_dts
    remove_column :physical_objects, :sound_format_digital_dolby_digital
    remove_column :physical_objects, :sound_format_sound_on_separate_media
    remove_column :physical_objects, :sound_content_music_track
    remove_column :physical_objects, :sound_content_effects_track
    remove_column :physical_objects, :sound_content_dialog
    remove_column :physical_objects, :sound_content_composite_track
    remove_column :physical_objects, :sound_content_outtakes
    remove_column :physical_objects, :sound_configuration_mono
    remove_column :physical_objects, :sound_configuration_stereo
    remove_column :physical_objects, :sound_configuration_surround
    remove_column :physical_objects, :sound_configuration_multi_track
    remove_column :physical_objects, :sound_configuration_dual_mono
    remove_column :physical_objects, :ad_strip
    remove_column :physical_objects, :shrinkage
    remove_column :physical_objects, :mold
    remove_column :physical_objects, :missing_footage
    remove_column :physical_objects, :multiple_items_in_can
    remove_column :physical_objects, :color_bw_color_color
    remove_column :physical_objects, :color_bw_bw_black_and_white
    remove_column :physical_objects, :color_bw_bw_hand_coloring
    remove_column :physical_objects, :color_bw_bw_stencil_coloring
    remove_column :physical_objects, :captions_or_subtitles_notes
    remove_column :physical_objects, :sound_format_optical
    remove_column :physical_objects, :anamorphic
    remove_column :physical_objects, :track_count
    remove_column :physical_objects, :generation_original_camera
    remove_column :physical_objects, :generation_master
    remove_column :physical_objects, :sound_format_digital_dolby_digital_sr
    remove_column :physical_objects, :sound_format_digital_dolby_digital_a
    remove_column :physical_objects, :stock_3_m
    remove_column :physical_objects, :stock_agfa_gevaert
    remove_column :physical_objects, :stock_pathe
    remove_column :physical_objects, :stock_unknown
    remove_column :physical_objects, :aspect_ratio_2_66_1
    remove_column :physical_objects, :aspect_ratio_1_36
    remove_column :physical_objects, :aspect_ratio_1_18
    remove_column :physical_objects, :picture_titles
    remove_column :physical_objects, :generation_other
    remove_column :physical_objects, :sound_content_narration
    remove_column :physical_objects, :close_caption
    remove_column :physical_objects, :generation_notes
  end
end
