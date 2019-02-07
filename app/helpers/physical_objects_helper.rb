module PhysicalObjectsHelper
  include MailHelper

  GAUGES_TO_FRAMES_PER_FOOT = {
	  '8mm' => 72, 'Super 8mm' => 72, '9.5mm' => 40.5, '16mm' => 40, 'Super 16mm' => 40, '28mm' => 20.5, '35mm' => 16, '35/32mm' => 40, '70mm' => 12.8
  }

  def hh_mm_sec(totalSeconds)
	  hh = (totalSeconds / 3600).floor
	  mm = ((totalSeconds - (hh * 3600)) / 60).floor
	  ss = totalSeconds - (hh * 3600) - (mm * 60)
	  "#{hh}:#{"%02d" % mm}:#{"%02d" % ss}"
  end

  # this should be used by any action that a creates a physical object from form submission
  def create_physical_object
    @physical_object = PhysicalObject.new(physical_object_params)
    user = User.current_user_object
    @physical_object.inventoried_by = user.id
    @physical_object.modified_by = user.id
    begin
      PhysicalObject.transaction do
        process_titles
        status_name = (User.current_user_object.worksite_location == 'ALF' ? WorkflowStatus::JUST_INVENTORIED_ALF : WorkflowStatus::JUST_INVENTORIED_WELLS)
        ws = WorkflowStatus.build_workflow_status(status_name, @physical_object)
				@physical_object.workflow_statuses << ws
        respond_to do |format|
          if @physical_object.save
            @url = nil
            if controller_name == 'physical_objects'
              action_name == 'new_physical_object' ?
                  @url = new_physical_object_path :
                  @url = duplicate_physical_object_path(@physical_object.id)
            elsif controller_name == 'collections'
              @url = collection_new_physical_object_path
            elsif controller_name == 'series'
              @url = series_new_physical_object_path
            elsif controller_name == 'titles'
              @url = title_new_physical_object_path
            end
            if @physical_object.base_nitrate
              notify_nitrate(@physical_object)
            end
            session[:physical_object_create_action] = @url
            format.html { redirect_to physical_object_path(@physical_object.id, notice: 'Physical Object successfully created')}
          else
            format.html { render 'physical_objects/new_physical_object' }
          end
        end
    end
    rescue Exception => error
      unless error.class == ManualRollBackError
        raise error
      end
      format.html { render 'physical_objects/new_physical_object' }
    end
  end

  def calc_estimated_duration(pos)
    d = 0
    pos.each do |p|
      fpf = PhysicalObjectsHelper::GAUGES_TO_FRAMES_PER_FOOT[p.gauge].nil? ? 0 : PhysicalObjectsHelper::GAUGES_TO_FRAMES_PER_FOOT[p.gauge]
      d += (fpf * (p.footage.blank? ? 0 : p.footage)) / 24
    end
    d
  end

  # Titles are now a many to many with physical objects - as a result whenever we process the title_ids passed in through the form, we need to examine if any PhysicalObjectTitles (join object)
  # exist that are not represented in the passed ids. These non-represented ids are titles that were associated with the physical object but have been disacciated (through a edit/update call
  # in physical_objects_controller)
  def process_titles
    # easiest to just delete all physical object/title associations then rebuild them based on what was passed
    @physical_object.physical_object_titles.delete_all
    titles = Title.where(id: params[:physical_object][:title_ids].split(',').collect { |n| n.to_i} )
    titles.each do |t|
      @physical_object.physical_object_titles << PhysicalObjectTitle.new(physical_object_id: @physical_object.id, title_id: t.id)
    end
  end

  private
  def physical_object_params
    params.require(:physical_object).permit(
        :location, :media_type, :medium, :iu_barcode, :copy_right, :format, :spreadsheet_id, :inventoried_by, :alternative_title,
        :creator, :language, :accompanying_documentation, :notes, :unit_id, :collection_id,
        :first_edition, :second_edition, :third_edition, :fourth_edition, :abridged, :short, :long, :sample, :alf_shelf,
        :preview, :revised, :version_original, :captioned, :excerpt, :catholic, :domestic, :trailer,:english, :television,
        :x_rated, :gauge, :generation_projection_print, :generation_a_roll, :generation_b_roll,
        :generation_c_roll, :generation_d_roll, :generation_answer_print, :generation_composite, :generation_duplicate,
        :generation_edited, :generation_original_camera, :generation_fine_grain_master, :generation_intermediate,
        :generation_kinescope, :generation_magnetic_track, :generation_mezzanine, :generation_negative,
        :generation_optical_sound_track, :generation_original, :generation_outs_and_trims, :generation_positive, :generation_master,
        :generation_reversal, :generation_separation_master, :generation_work_print, :generation_mixed, :generation_other,
        :generation_notes, :reel_number,
        :can_size, :footage, :duration, :base_acetate, :base_polyester, :base_nitrate, :base_mixed, :stock_agfa, :stock_ansco,
        :stock_dupont, :stock_orwo, :stock_fuji, :stock_gevaert, :stock_kodak, :stock_ferrania, :format_notes,
        :picture_not_applicable, :picture_silent_picture, :picture_mos_picture, :picture_composite_picture, :picture_intertitles_only,
        :picture_credits_only, :picture_picture_effects, :picture_picture_outtakes, :picture_kinescope, :picture_titles, :frame_rate,
        :sound_format_digital_dolby_digital_sr, :sound_format_digital_dolby_digital_a, :stock_3_m, :stock_agfa_gevaert, :stock_pathe,
        :stock_unknown, :aspect_ratio_2_66_1,

        :color_bw_bw_black_and_white, :color_bw_color_color, :color_bw_bw_toned, :color_bw_bw_tinted,
        :color_bw_color_ektachrome, :color_bw_color_kodachrome, :color_bw_color_technicolor,
        :color_bw_color_anscochrome, :color_bw_color_eco, :color_bw_color_eastman,
        :color_bw_bw_hand_coloring, :color_bw_bw_stencil_coloring,

        :aspect_ratio_1_33_1, :aspect_ratio_1_37_1, :aspect_ratio_1_66_1, :aspect_ratio_1_85_1, :aspect_ratio_2_35_1,
        :aspect_ratio_2_39_1, :aspect_ratio_2_59_1, :aspect_ratio_1_36, :aspect_ratio_1_18, :close_caption, :captions_or_subtitles_notes,
        :sound, :sound_format_optical, :sound_format_optical_variable_area, :sound_format_optical_variable_density, :sound_format_magnetic,
        :sound_format_digital_sdds, :sound_format_digital_dts, :sound_format_digital_dolby_digital, :sound_format_sound_on_separate_media,
        :sound_content_music_track, :sound_content_effects_track, :sound_content_dialog, :sound_content_composite_track, :sound_content_outtakes, :sound_content_narration,
        :sound_configuration_mono, :sound_configuration_stereo, :sound_configuration_surround, :sound_configuration_multi_track,
        :sound_configuration_dual_mono, :sound_configuration_single, :ad_strip, :shrinkage, :mold, :color_fade, :perforation_damage, :water_damage,
        :warp, :brittle, :splice_damage, :dirty, :channeling, :peeling, :tape_residue, :broken, :tearing, :poor_wind, :not_on_core_or_reel, :missing_footage,
        :scratches, :condition_rating, :condition_notes, :research_value, :research_value_notes, :conservation_actions, :multiple_items_in_can,
        :mdpi_barcode, :color_bw_color, :color_bw_bw, :accompanying_documentation_location, :lacquer_treated, :replasticized,
        :spoking, :dusty, :rusty, :miscellaneous, :title_control_number, :catalog_key, :anamorphic, :track_count, :compilation,
        value_conditions_attributes: [:id, :condition_type, :value, :comment, :_destroy],
        boolean_conditions_attributes: [:id, :condition_type, :comment, :_destroy],
        languages_attributes: [:id, :language, :language_type, :_destroy],
        physical_object_original_identifiers_attributes: [:id, :identifier, :_destroy],
        physical_object_dates_attributes: [:id, :controlled_vocabulary_id, :date, :_destroy]
    )
  end
end
