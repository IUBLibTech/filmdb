module PhysicalObjectsHelper
  include MailHelper
  # this should be used by any action that a creates a physical object from form submission
  def create_physical_object
    @physical_object = PhysicalObject.new(physical_object_params)
    user = User.current_user_object
    @physical_object.inventoried_by = user.id
    @physical_object.modified_by = user.id

    process_series_title

    respond_to do |format|
      if @physical_object.save
        url = nil
        if controller_name == 'physical_objects'
          if action_name == 'create_duplicate'
            #format.html { redirect_to duplicate_physical_object_path(@physical_object.id), notice: 'Physical Object successfully duplicated'}
          else
            url = new_physical_object_path
            #format.html { redirect_to new_physical_object_path , notice: 'Physical Object successfully created' }
          end
        elsif controller_name == 'collections'
          #format.html { redirect_to  collection_new_physical_object_path , notice: 'Physical Object successfully created' }
          url = collection_new_physical_object_path
        elsif controller_name == 'series'
          #format.html { redirect_to series_new_physical_object_path, notice: 'Physical Object successfully created'}
          url = series_new_physical_object_path
        elsif controller_name == 'titles'
          #format.html { redirect_to title_new_physical_object_path, notice: 'Physical Object successfully created'}
          url = title_new_physical_object_path
        end
        if @physical_object.base_nitrate
          notify_nitrate(@physical_object)
        end
        session[:physical_object_create_action] = url
        format.html { redirect_to physical_object_path(@physical_object.id, notice: 'Physical Object successfully created')}
      else
        format.html { render 'physical_objects/new_physical_object' }
      end
    end
  end

  # Series and Title creation can happen through physical object creation. The form autocompletes Title.title_text
  # and Series.title passing in existing series/titles as hidden params in the hash. But if a non-existing title/series
  # is specified by the user, series_title_text or title_text will contain a value while the hidden id element will not.
  # When this happens, the following combinations are possible:
  #
  # 1) new series and new title
  # 2) new series with existing title
  # 4) new title with existing series or not series specified
  def process_series_title
    new_series = params[:physical_object][:series_id].blank? && !params[:physical_object][:series_title_text].blank?
    new_title = params[:physical_object][:title_id].blank? && !params[:physical_object][:title_text].blank?

    if new_series && new_title
      @series = Series.new(title: params[:physical_object][:series_title_text], summary: "*This description was auto-generated because a new_physical_object series was created at physical object creation/edit.*")
      @title = Title.new(title_text: params[:physical_object][:title_text], summary: "*This description was auto-generated because a new_physical_object title was created at physical object creation/edit.*")
      @series.save
      @title.series_id = @series.id
      @title.save
      @physical_object.title_id = @title.id
      @other_message = "Additionally the new Title <i>#{@title.title_text}</i>, and the new Series <i>#{@series.title}</i> were created."

      # these calls are necessary for physical_objects_controller#update because it uses physical_object.update_attributes(physical_object_params)
      params[:physical_object][:series_id] = @series.id
      params[:physical_object][:title_id] = @title.id

    elsif new_series
      @series = Series.new(title: params[:physical_object][:series_title_text], summary: "*This description was auto-generated because a new_physical_object series was created at physical object creation/edit.*")
      @series.save

      # this call is necessary for physical_objects_controller#update because it uses physical_object.update_attributes(physical_object_params)
      params[:physical_object][:series_id] = @series.id

      title = Title.find(params[:physical_object][:title_id])
      title.update_attributes(series_id: @series.id)
      @physical_object.title_id = title.id
      @other_message = "Additionally the new Series <i>#{@series.title}</i> was created."
    elsif new_title
      @title = Title.new(title_text: params[:physical_object][:title_text], summary: "*This description was auto-generated because a new_physical_object title was created at physical object creation/edit.*")
      #  either an existing series was specified or no series was specified
      if params[:physical_object][:series_id]
        @title.series_id =  params[:physical_object][:series_id]
      end
      @title.save

      # this call is necessary for physical_objects_controller#update because it uses physical_object.update_attributes(physical_object_params)
      params[:physical_object][:title_id] = @title.id

      @physical_object.title_id = @title.id
      @other_message = "Additionally the new Title <i>#{@title.title_text}</i> was created."
    end
    flash[:other_message] = @other_message
  end

  private
  def physical_object_params
    params.require(:physical_object).permit(
        :location, :media_type, :medium, :iu_barcode, :title_id, :copy_right, :format, :spreadsheet_id, :inventoried_by,
        :series_production_number, :series_part, :alternative_title, :title_version, :item_original_identifier,
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
        :picture_credits_only, :picture_effects, :picture_outtakes, :picture_kinescope, :frame_rate,
        :color_bw_bw_toned, :color_bw_bw_tinted, :color_bw_color_ektachrome, :color_bw_color_kodachrome, :color_bw_color_technicolor,
        :color_bw_color_ansochrome, :color_bw_color_eco, :color_bw_color_eastman,
        :color_bw_bw_hand_coloring, :color_bw_bw_stencil_coloring, :aspect_ratio_1_33_1, :aspect_ratio_1_37_1, :aspect_ratio_1_66_1, :aspect_ratio_1_85_1, :aspect_ratio_2_35_1,
        :aspect_ratio_2_39_1, :aspect_ratio_2_59_1, :language_arabic, :language_chinese, :language_english, :language_french, :language_german,
        :language_hindi, :language_italian, :language_japanese, :language_portuguese, :language_russian, :language_spanish, :close_caption,
        :sound, :sound_format_optical_variable_area, :sound_format_optical_variable_density, :sound_format_magnetic, :sound_format_mixed,
        :sound_format_digital_sdds, :sound_format_digital_dts, :sound_format_digital_dolby_digital, :sound_format_sound_on_separate_media,
        :sound_content_music_track, :sound_content_effects_track, :sound_content_dialog, :sound_content_composite_track, :sound_content_outtakes,
        :sound_configuration_mono, :sound_configuration_stereo, :sound_configuration_surround, :sound_configuration_multi_track,
        :sound_configuration_dual, :sound_configuration_single, :ad_strip, :shrinkage, :mold, :color_fade, :perforation_damage, :water_damage,
        :warp, :brittle, :splice_damage, :dirty, :channeling, :peeling, :tape_residue, :broken, :tearing, :poor_wind, :not_on_core_or_reel, :missing_footage,
        :scratches, :condition_rating, :condition_notes, :research_value, :research_value_notes, :conservation_actions, :multiple_items_in_can,
        :mdpi_barcode, :color_bw_color, :color_bw_bw, :accompanying_documentation_location, :lacquer_treated, :replasticized,
        :spoking, :dusty, :rusty, :miscellaneous, :title_control_number,
        value_conditions_attributes: [:id, :condition_type, :value, :comment, :_destroy],
        boolean_conditions_attributes: [:id, :condition_type, :comment, :_destroy]
    )
  end
end
