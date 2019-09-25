class AddVideoMetadataFields < ActiveRecord::Migration
  def change
    # version fields
    add_column :videos, :first_edition, :boolean
    add_column :videos, :second_edition, :boolean
    add_column :videos, :third_edition, :boolean
    add_column :videos, :fourth_edition, :boolean
    add_column :videos, :abridged, :boolean
    add_column :videos, :short, :boolean
    add_column :videos, :long, :boolean
    add_column :videos, :sample, :boolean
    add_column :videos, :revised, :boolean
    add_column :videos, :original, :boolean
    add_column :videos, :excerpt, :boolean
    add_column :videos, :catholic, :boolean
    add_column :videos, :domestic, :boolean
    add_column :videos, :trailer, :boolean
    add_column :videos, :english, :boolean
    add_column :videos, :non_english, :boolean
    add_column :videos, :television, :boolean
    add_column :videos, :x_rated, :boolean

    # do not add gauge, it was created in the original Videos migration file
    
    # generation fields
    add_column :videos, :generation_b_roll, :boolean
    add_column :videos, :generation_commercial_release, :boolean
    add_column :videos, :generation_copy_access, :boolean
    add_column :videos, :generation_dub, :boolean
    add_column :videos, :generation_duplicate, :boolean
    add_column :videos, :generation_edited, :boolean
    add_column :videos, :generation_fine_cut, :boolean
    add_column :videos, :generation_intermediate, :boolean
    add_column :videos, :generation_line_cut, :boolean
    add_column :videos, :generation_master, :boolean
    add_column :videos, :generation_master_production, :boolean
    add_column :videos, :generation_master_distribution, :boolean
    add_column :videos, :generation_off_air_recording, :boolean
    add_column :videos, :generation_original, :boolean
    add_column :videos, :generation_picture_lock, :boolean
    add_column :videos, :generation_rough_cut, :boolean
    add_column :videos, :generation_stock_footage, :boolean
    add_column :videos, :generation_submaster, :boolean
    add_column :videos, :generation_work_tapes, :boolean
    add_column :videos, :generation_work_track, :boolean
    add_column :videos, :generation_other, :boolean

    add_column :videos, :reel_number, :string
    add_column :videos, :size, :string
    add_column :videos, :recording_standard, :string
    add_column :videos, :maximum_runtime, :string
    add_column :videos, :duration, :integer
    add_column :videos, :base, :string
    add_column :videos, :stock, :string
    
    # image fields
    add_column :videos, :picture_type_not_applicable, :boolean
    add_column :videos, :picture_type_silent_picture, :boolean
    add_column :videos, :picture_type_mos_picture, :boolean
    add_column :videos, :picture_type_composite_picture, :boolean
    add_column :videos, :picture_type_credits_only, :boolean
    add_column :videos, :picture_type_picture_effects, :boolean
    add_column :videos, :picture_type_picture_outtakes, :boolean
    add_column :videos, :picture_type_other, :boolean
    add_column :videos, :playback_speed, :string
    add_column :videos, :image_color_bw, :boolean
    add_column :videos, :image_color_color, :boolean
    add_column :videos, :image_color_mixed, :boolean
    add_column :videos, :image_color_other, :boolean
    add_column :videos, :image_aspect_ratio_4_3, :boolean
    add_column :videos, :image_aspect_ratio_16_9, :boolean
    add_column :videos, :image_aspect_ratio_other, :boolean

    # sound field
    add_column :videos, :caption_or_subtitles, :boolean
    add_column :videos, :notes, :text
    add_column :videos, :silent, :boolean
    add_column :videos, :sound_format_type_magnetic, :boolean
    add_column :videos, :sound_format_type_digital, :boolean
    add_column :videos, :sound_format_type_sound_on_separate_media, :boolean
    add_column :videos, :sound_format_type_other, :boolean
    add_column :videos, :sound_content_type_music_track, :boolean
    add_column :videos, :sound_content_type_effects_track, :boolean
    add_column :videos, :sound_content_type_dialog, :boolean
    add_column :videos, :sound_content_type_composite_track, :boolean
    add_column :videos, :sound_content_type_outtakes, :boolean
    add_column :videos, :sound_configuration_mono, :boolean
    add_column :videos, :sound_configuration_stereo, :boolean
    add_column :videos, :sound_configuration_surround, :boolean
    add_column :videos, :sound_configuration_other, :boolean
    add_column :videos, :sound_noise_redux_dolby_a, :boolean
    add_column :videos, :sound_noise_redux_dolby_b, :boolean
    add_column :videos, :sound_noise_redux_dolby_c, :boolean
    add_column :videos, :sound_noise_redux_dolby_s, :boolean
    add_column :videos, :sound_noise_redux_dolby_sr, :boolean
    add_column :videos, :sound_noise_redux_dolby_nr, :boolean
    add_column :videos, :sound_noise_redux_dolby_hx, :boolean
    add_column :videos, :sound_noise_redux_dolby_hx_pro, :boolean
    add_column :videos, :sound_noise_redux_dbx, :boolean
    add_column :videos, :sound_noise_redux_dbx_type_1, :boolean
    add_column :videos, :sound_noise_redux_dbx_type_2, :boolean
    add_column :videos, :sound_noise_redux_high_com, :boolean
    add_column :videos, :sound_noise_redux_high_com_2, :boolean
    add_column :videos, :sound_noise_redux_adres, :boolean
    add_column :videos, :sound_noise_redux_anrs, :boolean
    add_column :videos, :sound_noise_redux_dnl, :boolean
    add_column :videos, :sound_noise_redux_dnr, :boolean
    add_column :videos, :sound_noise_redux_cedar, :boolean
    add_column :videos, :sound_noise_redux_none, :boolean

    add_column :videos, :mold, :string
    add_column :videos, :playback_issues_video_artifacts, :text
    add_column :videos, :playback_issues_audio_artifacts, :text

    add_column :videos, :missing_footage, :text

  end
end
