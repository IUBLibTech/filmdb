module PhysicalObjectsHelper
  include MailHelper

  # attributes that belong to the base PhysicalObject model
  PO_ONLY_ATTRIBTUES = [:location, :media_type, :medium, :iu_barcode, :format, :spreadsheet_id, :inventoried_by, :alternative_title,
                        :creator, :language, :accompanying_documentation, :notes, :unit_id, :collection_id, :alf_shelf, :duration,
                        :conservation_actions, :mdpi_barcode, :accompanying_documentation_location, :miscellaneous, :title_control_number,
                        :catalog_key, :compilation, :format_notes]

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
    @physical_object = physical_object_specific
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
            if @physical_object.is_a?(Film) && @physical_object.base_nitrate
              notify_nitrate(@physical_object)
            end
            session[:physical_object_create_action] = @url
            format.html { redirect_to physical_object_path(@physical_object.acting_as.id, notice: 'Physical Object successfully created')}
          else
            associate_titles
            set_cv
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
      p = p.specific
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
    associate_titles
  end

  # searches the params hash to find out what value is set in the medium attribute, params[:video][:medium], or params[:film][:medium]
  def medium_from_params
    key = class_symbol_from_params
    params[key][:medium]
  end


  # this finds what the user has selected from the MEDIUM attribute drop down and converts it to a symbol. See
  # find_original_physical_object_type below for more details
  def find_medium(params)
    type = class_symbol_from_params
    params[type][:medium].downcase.parameterize.underscore.to_sym
  end

  # This method extracts the Physical Object base class has key (:film, :video, etc) from the params hash.
  #
  # This is needed because when rails builds the form for a PhysicalObject, all attributes are named based on BASE
  # class and the the key to these is the base class: for instance, iu_barcode would be params[:film][:iu_barcode] if
  # the form was build around a Film object, params[:video][:iu_barcode] if the form was build around a Video object.
  # This results in a params hash with the key to the physical object attributes being the original form BASE
  # class: params[:film], params[:video], etc. This is mainly used when a user edits the Medium attribute for a
  # Physical Object. If a user creates a new Physical Object, the base class defaults to Film but when the user changes
  # that to video, a new form must be generated based on Video attributes. However, any physical object super class
  # attributes (barcodes, titles, etc) may have already been entered and these should be retained and copied into the
  # new physical object type
  def class_symbol_from_params
    type = nil
    type = :film if params[:film]
    type = :video if params[:video]
    raise "Invalid request - no supported formats specified: #{params.keys.join(', ')}" if type.nil?
    type
  end

  def blank_specific_po(medium)
    if medium == "Film" || medium == :film
      Film.new
    elsif medium == "Video" || medium == :video
      Video.new
    end
  end

  def new_format_specific_physical_object(medium)
    if medium == :film
      Film.new(physical_object_params)
    elsif medium == :video
      p = physical_object_params
      Video.new(p)
    else
      raise "Unsupported Physical Object Medium #{medium}"
    end
  end

  private
  def associate_titles
    titles = Title.where(id: params[:physical_object][:title_ids].split(',').collect { |n| n.to_i} )
    titles.each do |t|
      @physical_object.physical_object_titles << PhysicalObjectTitle.new(physical_object_id: @physical_object.id, title_id: t.id)
    end
  end
  def physical_object_specific
    if params[:film]
      Film.new(physical_object_params)
    elsif params[:video]
      Video.new(physical_object_params)
    else
      raise 'Unsupported Format'
    end
  end

  # returns a hash containing only the generic physical objects attributes hash
  def po_only_params
    hash = params.clone
    c = class_symbol_from_params
    hash.permit
    hash.require(c).permit(:location, :media_type, :medium, :iu_barcode, :format, :spreadsheet_id, :inventoried_by, :alternative_title,
                :creator, :language, :accompanying_documentation, :notes, :unit_id, :collection_id, :alf_shelf, :duration,
                :conservation_actions, :mdpi_barcode, :accompanying_documentation_location, :miscellaneous, :title_control_number,
                :catalog_key, :compilation, :format_notes)
    hash.keys.each do |k|
      hash.delete k unless PO_ONLY_ATTRIBTUES.include?(k)
    end
    hash
  end

  def physical_object_params
    if params[:film]
      params.require(:film).permit(
          # physical object specific attributes
          :location, :media_type, :medium, :iu_barcode, :format, :spreadsheet_id, :inventoried_by, :alternative_title,
          :creator, :language, :accompanying_documentation, :notes, :unit_id, :collection_id, :alf_shelf, :duration,
          :conservation_actions, :mdpi_barcode, :accompanying_documentation_location, :miscellaneous, :title_control_number,
          :catalog_key, :compilation, :format_notes,

          # film specific attributes
          :gauge, :reel_number, :can_size, :footage, :frame_rate, :ad_strip, :shrinkage, :mold,
          :missing_footage, :condition_rating, :condition_notes, :research_value, :research_value_notes, :multiple_items_in_can,
          # version attributes
          :first_edition, :second_edition, :third_edition, :fourth_edition, :abridged, :short, :long, :sample,
          :preview, :revised, :version_original, :captioned, :excerpt, :catholic, :domestic, :trailer,:english, :television,
          :x_rated,
          # generation
          :generation_projection_print, :generation_a_roll, :generation_b_roll,
          :generation_c_roll, :generation_d_roll, :generation_answer_print, :generation_composite, :generation_duplicate,
          :generation_edited, :generation_original_camera, :generation_fine_grain_master, :generation_intermediate,
          :generation_kinescope, :generation_magnetic_track, :generation_mezzanine, :generation_negative,
          :generation_optical_sound_track, :generation_original, :generation_outs_and_trims, :generation_positive, :generation_master,
          :generation_reversal, :generation_separation_master, :generation_work_print, :generation_mixed, :generation_other,
          :generation_notes,
          # base, stock
          :base_acetate, :base_polyester, :base_nitrate, :base_mixed, :stock_agfa, :stock_ansco,
          :stock_dupont, :stock_orwo, :stock_fuji, :stock_gevaert, :stock_kodak, :stock_ferrania,
          # picture attributes
          :picture_not_applicable, :picture_silent_picture, :picture_mos_picture, :picture_composite_picture, :picture_intertitles_only,
          :picture_credits_only, :picture_picture_effects, :picture_picture_outtakes, :picture_kinescope, :picture_titles,

          # color attributes
          :color_bw_bw_black_and_white, :color_bw_color_color, :color_bw_bw_toned, :color_bw_bw_tinted,
          :color_bw_color_ektachrome, :color_bw_color_kodachrome, :color_bw_color_technicolor,
          :color_bw_color_anscochrome, :color_bw_color_eco, :color_bw_color_eastman,
          :color_bw_bw_hand_coloring, :color_bw_bw_stencil_coloring, :color_bw_color, :color_bw_bw,
          #aspect ratios
          :aspect_ratio_2_66_1, :aspect_ratio_1_33_1, :aspect_ratio_1_37_1, :aspect_ratio_1_66_1, :aspect_ratio_1_85_1, :aspect_ratio_2_35_1,
          :aspect_ratio_2_39_1, :aspect_ratio_2_59_1, :aspect_ratio_1_36, :aspect_ratio_1_18,
          :anamorphic,
          # sound attributes
          :sound_format_digital_dolby_digital_sr, :sound_format_digital_dolby_digital_a, :stock_3_m, :stock_agfa_gevaert, :stock_pathe,
          :stock_unknown, :close_caption, :captions_or_subtitles_notes, :sound, :sound_format_optical, :sound_format_optical_variable_area,
          :sound_format_optical_variable_density, :sound_format_magnetic, :sound_format_digital_sdds, :sound_format_digital_dts,
          :sound_format_digital_dolby_digital, :sound_format_sound_on_separate_media, :sound_content_music_track,
          :sound_content_effects_track, :sound_content_dialog, :sound_content_composite_track, :sound_content_outtakes,
          :sound_content_narration, :sound_configuration_mono, :sound_configuration_stereo, :sound_configuration_surround,
          :sound_configuration_multi_track, :sound_configuration_dual_mono, :sound_configuration_single,
          :track_count,

          value_conditions_attributes: [:id, :condition_type, :value, :comment, :_destroy],
          boolean_conditions_attributes: [:id, :condition_type, :comment, :_destroy],
          languages_attributes: [:id, :language, :language_type, :_destroy],
          physical_object_original_identifiers_attributes: [:id, :identifier, :_destroy],
          physical_object_dates_attributes: [:id, :controlled_vocabulary_id, :date, :_destroy]
      )
    elsif params[:video]
      params.require(:video).permit(
          # physical object specific attributes
          :location, :media_type, :medium, :iu_barcode, :format, :spreadsheet_id, :inventoried_by, :alternative_title,
          :creator, :language, :accompanying_documentation, :notes, :unit_id, :collection_id, :alf_shelf, :duration,
          :conservation_actions, :mdpi_barcode, :accompanying_documentation_location, :miscellaneous, :title_control_number,
          :catalog_key, :compilation, :format_notes,

          # video specific attributes
          :gauge, :first_edition, :second_edition, :third_edition, :fourth_edition, :abridged, :short, :long, :sample, :revised,
          :original, :excerpt, :catholic, :domestic, :trailer, :english, :television, :x_rated, :generation_b_roll,
          :generation_commercial_release, :generation_copy_access, :generation_dub, :generation_duplicate, :generation_edited,
          :generation_fine_cut, :generation_intermediate, :generation_line_cut, :generation_master, :generation_master_production,
          :generation_master_distribution, :generation_off_air_recording, :generation_original, :generation_picture_lock,
          :generation_rough_cut, :generation_stock_footage, :generation_submaster, :generation_work_tapes, :generation_work_track,
          :reel_number, :size, :recording_standard, :maximum_runtime, :duration, :base, :stock,
          :playback_speed, :picture_type_not_applicablem, :picture_type_silent_picture, :picture_type_mos_picture, :picture_type_composite_picture,
          :picture_type_credits_only, :picture_type_picture_effects, :picture_type_picture_outtakes, :picture_type_other,
          :image_color_bw, :image_color_color, :image_color_mixed, :image_color_other, :image_aspect_ratio_4_3, :image_aspect_ratio_16_9,
          :image_aspect_ratio_other, :captions_or_subtitles, :silent, :sound_format_type_magnetic, :sound_format_type_digital,
          :sound_format_type_sound_on_separate_media, :sound_format_type_other, :sound_content_type_music_track, :sound_content_type_effects_track,
          :sound_content_type_dialog, :sound_content_type_composite_track, :sound_content_type_outtakes, :sound_configuration_mono,
          :sound_configuration_stereo, :sound_configuration_surround, :sound_configuration_other, :sound_noise_redux_dolby_a,
          :sound_noise_redux_dolby_b, :sound_noise_redux_dolby_c, :sound_noise_redux_dolby_s, :sound_noise_redux_dolby_sr,
          :sound_noise_redux_dolby_nr, :sound_noise_redux_dolby_hx, :sound_noise_redux_dolby_hx_pro, :sound_noise_redux_dbx,
          :sound_noise_redux_dbx_type_1, :sound_noise_redux_dbx_type_2, :sound_noise_redux_high_com, :sound_noise_redux_high_com_2,
          :sound_noise_redux_adres, :sound_noise_redux_anrs, :sound_noise_redux_dnl, :sound_noise_redux_dnr, :sound_noise_redux_cedar,
          :sound_noise_redux_none, :notes, :condition_rating, :condition_notes, :research_value, :research_value_notes, :mold,

          value_conditions_attributes: [:id, :condition_type, :value, :comment, :_destroy],
          boolean_conditions_attributes: [:id, :condition_type, :comment, :_destroy],
          languages_attributes: [:id, :language, :language_type, :_destroy],
          physical_object_original_identifiers_attributes: [:id, :identifier, :_destroy],
          physical_object_dates_attributes: [:id, :controlled_vocabulary_id, :date, :_destroy]
      )
    else
      raise "Unsupported Format #{params[:physical_object][:medium]}"
    end
  end

end
