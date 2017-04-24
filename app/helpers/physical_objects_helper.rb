module PhysicalObjectsHelper
  include MailHelper
  # this should be used by any action that a creates a physical object from form submission
  def create_physical_object
    @physical_object = PhysicalObject.new(physical_object_params)
    user = User.current_user_object
    @physical_object.inventoried_by = user.id
    @physical_object.modified_by = user.id
    begin
      PhysicalObject.transaction do
        process_titles
				#FIXME: determine if we need to do something other than setting workflow status on newly created physical objects to "in storage"
				@physical_object.workflow_statuses << WorkflowStatus.new(physical_object_id: @physical_object.id, workflow_status_template_id: WorkflowStatusTemplate.order(:sort_order).last.id)
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
      unless error.class == ManualRollBackException
        raise error
      end
      format.html { render 'physical_objects/new_physical_object' }
    end
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
    # old code - we can no longer do this because titles <-> series is a one to one by title <-> physical object is many to many: there's no uncomplicated user inteface
    # that allows associating series and title together...

    # @title = params[:physical_object][:title_id].blank? ? nil : Title.find(params[:physical_object][:title_id])
    # return if @title.nil?
    # existing_series = !params[:physical_object][:series_id].blank?
    # if existing_series
    #   @series = Series.find(params[:physical_object][:series_id])
    # end
    #
    # if existing_series && !@title.series_id.nil? && @title.series_id != @series.id
    #   @physical_object.errors.add(:title, "Title already has existing Series - attempt to assign another Series")
    #   @other_message = "Attempt to assign a different Series to a Title that already has Series"
    #   raise ManualRollBackException.new("Attemp to assign this title a different series when it has a series")
    # else
    #   @physical_object.physical_object_titles << PhysicalObjectTitle.new(physical_object_id: @physical_object.id, title_id: @title.id)
    #   @other_message = "Additionally the new Title <i>#{@title.title_text}</i> was created."
    #   params[:physical_object][:series_id] = @series.nil? ? nil : @series.id
    #   params[:physical_object][:title_id] = @title.id
    # end
    # flash[:other_message] = @other_message
  end

  private
  def physical_object_params
    params.require(:physical_object).permit(
        :location, :media_type, :medium, :iu_barcode, :copy_right, :format, :spreadsheet_id, :inventoried_by,
        :series_production_number, :series_part, :alternative_title,
        :creator, :language, :accompanying_documentation, :notes, :unit_id, :collection_id,
        :access, :first_edition, :second_edition, :third_edition, :fourth_edition, :abridged, :short, :long, :sample,
        :preview, :revised, :version_original, :captioned, :excerpt, :catholic, :domestic, :trailer,:english, :television,
        :x_rated, :gauge, :generation_projection_print, :generation_a_roll, :generation_b_roll,
        :generation_c_roll, :generation_d_roll, :generation_answer_print, :generation_composite, :generation_duplicate,
        :generation_edited, :generation_edited_camera_original, :generation_fine_grain_master, :generation_intermediate,
        :generation_kinescope, :generation_magnetic_track, :generation_mezzanine, :generation_negative,
        :generation_optical_sound_track, :generation_original, :generation_outs_and_trims, :generation_positive,
        :generation_reversal, :generation_separation_master, :generation_work_print, :generation_mixed, :reel_number,
        :can_size, :footage, :duration, :base_acetate, :base_polyester, :base_nitrate, :base_mixed, :stock_agfa, :stock_ansco,
        :stock_dupont, :stock_orwo, :stock_fuji, :stock_gevaert, :stock_kodak, :stock_ferrania, :stock_mixed, :format_notes,
        :picture_not_applicable, :picture_silent_picture, :picture_mos_picture, :picture_composite_picture, :picture_intertitles_only,
        :picture_credits_only, :picture_picture_effects, :picture_picture_outtakes, :picture_kinescope, :frame_rate,

        :color_bw_bw_black_and_white, :color_bw_color_color, :color_bw_bw_toned, :color_bw_bw_tinted,
        :color_bw_color_ektachrome, :color_bw_color_kodachrome, :color_bw_color_technicolor,
        :color_bw_color_ansochrome, :color_bw_color_eco, :color_bw_color_eastman,
        :color_bw_bw_hand_coloring, :color_bw_bw_stencil_coloring,

        :aspect_ratio_1_33_1, :aspect_ratio_1_37_1, :aspect_ratio_1_66_1, :aspect_ratio_1_85_1, :aspect_ratio_2_35_1,
        :aspect_ratio_2_39_1, :aspect_ratio_2_59_1, :close_caption, :captions_or_subtitles_notes,
        :sound, :sound_format_optical, :sound_format_optical_variable_area, :sound_format_optical_variable_density, :sound_format_magnetic, :sound_format_mixed,
        :sound_format_digital_sdds, :sound_format_digital_dts, :sound_format_digital_dolby_digital, :sound_format_sound_on_separate_media,
        :sound_content_music_track, :sound_content_effects_track, :sound_content_dialog, :sound_content_composite_track, :sound_content_outtakes,
        :sound_configuration_mono, :sound_configuration_stereo, :sound_configuration_surround, :sound_configuration_multi_track,
        :sound_configuration_dual, :sound_configuration_single, :ad_strip, :shrinkage, :mold, :color_fade, :perforation_damage, :water_damage,
        :warp, :brittle, :splice_damage, :dirty, :channeling, :peeling, :tape_residue, :broken, :tearing, :poor_wind, :not_on_core_or_reel, :missing_footage,
        :scratches, :condition_rating, :condition_notes, :research_value, :research_value_notes, :conservation_actions, :multiple_items_in_can,
        :mdpi_barcode, :color_bw_color, :color_bw_bw, :accompanying_documentation_location, :lacquer_treated, :replasticized,
        :spoking, :dusty, :rusty, :miscellaneous, :title_control_number, :anamorphic, :track_count,
        value_conditions_attributes: [:id, :condition_type, :value, :comment, :_destroy],
        boolean_conditions_attributes: [:id, :condition_type, :comment, :_destroy],
        languages_attributes: [:id, :language, :language_type, :_destroy],
        physical_object_original_identifiers_attributes: [:id, :identifier, :_destroy]
    )
  end
end
