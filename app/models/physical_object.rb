class PhysicalObject < ActiveRecord::Base
	include ActiveModel::Validations

	belongs_to :title
	belongs_to :spreadhsheet
	belongs_to :collection, autosave: true
	belongs_to :unit, autosave: true
	belongs_to :inventorier, class_name: "User", foreign_key: "inventoried_by", autosave: true
	belongs_to :modifier, class_name: "User", foreign_key: "modified_by", autosave: true
  belongs_to :cage_shelf
	belongs_to :active_component_group, class_name: 'ComponentGroup', foreign_key: 'component_group_id', autosave: true

	has_many :physical_object_old_barcodes
  has_many :component_group_physical_objects, dependent: :delete_all
  has_many :component_groups, through: :component_group_physical_objects
  has_many :physical_object_titles, dependent: :delete_all
  has_many :titles, through: :physical_object_titles
	has_many :series, through: :titles
	has_many :physical_object_dates
	has_many :physical_object_pull_requests
	has_many :pull_requests, through: :physical_object_pull_requests

  validates :physical_object_titles, physical_object_titles: true
  validates :iu_barcode, iu_barcode: true
	validates :mdpi_barcode, mdpi_barcode: true
  validates :unit, presence: true
  validates :media_type, presence: true
  validates :medium, presence: true
	validates :gauge, presence: true

  has_many :boolean_conditions, autosave: true
  has_many :value_conditions, autosave: true
  has_many :languages, autosave: true
  has_many :physical_object_original_identifiers
	has_many :workflow_statuses

  accepts_nested_attributes_for :boolean_conditions, allow_destroy: true
  accepts_nested_attributes_for :value_conditions, allow_destroy: true
  accepts_nested_attributes_for :languages, allow_destroy: true
  accepts_nested_attributes_for :physical_object_original_identifiers, allow_destroy: true
	accepts_nested_attributes_for :physical_object_dates, allow_destroy: true

	attr_accessor :workflow
	attr_accessor :updated

	trigger.after(:update).of(:iu_barcode) do
		"INSERT INTO physical_object_old_barcodes(physical_object_id, iu_barcode) VALUES(OLD.id, OLD.iu_barcode)"
	end

	# returns all physical whose workflow status matches any specified in *status - use WorkflowStatus status constants as values
	scope :where_current_workflow_status_is, lambda { |*status|
		sql = "SELECT physical_objects.* "+
			"FROM ( SELECT workflow_statuses.physical_object_id "+
			  "FROM (	SELECT physical_object_id, max(created_at) AS status FROM workflow_statuses GROUP BY physical_object_id) AS x "+
			    "INNER JOIN workflow_statuses on (workflow_statuses.physical_object_id = x.physical_object_id AND x.status = workflow_statuses.created_at) "+
			    "WHERE workflow_statuses.status_name in (#{status.map(&:inspect).join(', ')})) as y INNER JOIN physical_objects on physical_object_id = physical_objects.id"
		PhysicalObject.find_by_sql(sql)
	}

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
      :preview, :revised, :version_original, :captioned, :excerpt, :catholic, :domestic, :trailer, :english, :television, :x_rated]
  VERSION_FIELDS_HUMANIZED = {first_edition: "1st Edition", second_edition: "2nd Edition", third_edition: "3rd Edition", fourth_edition: "4th Edition", x_rated: "X-rated"}

  GENERATION_FIELDS = [
                    :generation_negative, :generation_positive, :generation_reversal, :generation_projection_print, :generation_answer_print, :generation_work_print,
                    :generation_composite, :generation_intermediate, :generation_mezzanine, :generation_kinescope, :generation_magnetic_track, :generation_optical_sound_track,
                    :generation_outs_and_trims, :generation_a_roll, :generation_b_roll, :generation_c_roll, :generation_d_roll, :generation_edited,
                    :generation_original_camera, :generation_original, :generation_fine_grain_master, :generation_separation_master, :generation_duplicate, :generation_master
                    ]
  GENERATION_FIELDS_HUMANIZED = {
      generation_negative: "Negative", generation_positive: "Positive", generation_reversal: "Reversal", generation_projection_print: "Projection Print",
      generation_answer_print: "Answer Print", generation_work_print: "Work Print", generation_composite: "Composite", generation_intermediate: "Intermediate",
      generation_mezzanine: "Mezzanine", generation_kinescope: "Kinescope", generation_magnetic_track: "Magnetic Track", generation_optical_sound_track: "Optical Soundtrack",
      generation_outs_and_trims: "Outs and Trims", generation_a_roll: "A Roll", generation_b_roll: "B Roll", generation_c_roll: "C Roll", generation_d_roll: "D Roll",
      generation_edited: "Edited", generation_original_camera: "Original Camera", generation_original: "Original",
      generation_fine_grain_master: "Fine Grain Master", generation_separation_master: "Separation Master", generation_duplicate: "Duplicate", generation_master: 'Master'
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
      :picture_credits_only, :picture_picture_effects, :picture_picture_outtakes, :picture_kinescope
  ]
  PICTURE_TYPE_FIELDS_HUMANIZED = {
      picture_not_applicable: "Not Applicable", picture_silent_picture: "Silent", picture_mos_picture: "MOS",
      picture_composite_picture: "Composite", picture_intertitles_only: "Intertitles Only", picture_credits_only: "Credits Only",
      picture_picture_effects: "Picture Effects", picture_picture_outtakes: "Outtakes", picture_kinescope: "Kinescope"
  }
  COLOR_BW_FIELDS = [
      :color_bw_bw_toned, :color_bw_bw_tinted, :color_bw_bw_hand_coloring, :color_bw_bw_stencil_coloring, :color_bw_bw_black_and_white
  ]
  COLOR_COLOR_FIELDS = [
      :color_bw_color_ektachrome, :color_bw_color_kodachrome, :color_bw_color_technicolor,
      :color_bw_color_ansochrome, :color_bw_color_eco, :color_bw_color_eastman, :color_bw_color_color
  ]
  COLOR_FIELDS = COLOR_BW_FIELDS + COLOR_COLOR_FIELDS

  COLOR_FIELDS_HUMANIZED = {
      color_bw_bw_toned: "Toned (Black and White)", color_bw_bw_tinted: "Tinted (Black and White)", color_bw_color_ektachrome: "Ektachrome",
      color_bw_color_kodachrome: "Kodachrome", color_bw_color_technicolor: "Technicolor", color_bw_color_ansochrome: "Ansochrome",
      color_bw_color_eco: "Eco", color_bw_color_eastman: "Eastman", color_bw_bw: "Black and White", color_bw_bw_hand_coloring: "Hand Coloring",
      color_bw_bw_stencil_coloring: "Stencil Coloring", color_bw_color_color: "Color", color_bw_bw_black_and_white: 'Black & White'
  }

  ASPECT_RATIO_FIELDS = [
      :aspect_ratio_1_33_1, :aspect_ratio_1_37_1, :aspect_ratio_1_66_1, :aspect_ratio_1_85_1, :aspect_ratio_2_35_1, :aspect_ratio_2_39_1, :aspect_ratio_2_59_1
  ]
  ASPECT_RATIO_FIELDS_HUMANIZED = {
      aspect_ratio_1_33_1: "1.33:1", aspect_ratio_1_37_1: "1.37:1", aspect_ratio_1_66_1: "1.66:1", aspect_ratio_1_85_1: "1.85:1",
      aspect_ratio_2_35_1: "2.35:1", aspect_ratio_2_39_1: "2.39:1", aspect_ratio_2_59_1: "2.59:1"
  }

  SOUND_FORMAT_FIELDS = [
      :sound_format_optical, :sound_format_optical_variable_area, :sound_format_optical_variable_density, :sound_format_magnetic,
      :sound_format_mixed, :sound_format_digital_sdds, :sound_format_digital_dts, :sound_format_digital_dolby_digital,
      :sound_format_sound_on_separate_media
  ]
  SOUND_FORMAT_FIELDS_HUMANIZED = {
      sound_format_optical: 'Optical', sound_format_optical_variable_area: "Optical: Variable Area", sound_format_optical_variable_density: "Optical: Variable Density",
      sound_format_magnetic: "Magnetic", sound_format_type_mixed: "Mixed", sound_format_digital_sdds: "Digital: SDDS",
      sound_format_digital_dts: "Digital: DTS", sound_format_digital_dolby_digital: "Digital: Dolby Digital",
      sound_format_sound_on_separate_media: "Sound on Separate Media"
  }

  SOUND_CONTENT_FIELDS = [:sound_content_music_track, :sound_content_effects_track, :sound_content_dialog, :sound_content_composite_track, :sound_content_outtakes]
  SOUND_CONTENT_FIELDS_HUMANIZED = {
      sound_content_music_track: "Music Track", sound_content_effects_track: "Effects Track", sound_content_dialog: "Dialog",
      sound_content_composite_track: "Composite Track", sound_content_outtakes: "Outtakes"
  }

  SOUND_CONFIGURATION_FIELDS = [
      :sound_configuration_mono, :sound_configuration_stereo, :sound_configuration_surround, :sound_configuration_multi_track, :sound_configuration_dual_mono
  ]
  SOUND_CONFIGURATION_FIELDS_HUMANIZED = {
      sound_configuration_mono: "Mono", sound_configuration_stereo: "Stereo", sound_configuration_surround: "Surround",
      sound_configuration_multi_track: "Multi-track (ie. Maurer)", sound_configuration_dual_mono: "Dual Mono"
  }

  CONDITION_FIELDS = [
      :ad_strip, :shrinkage, :mold, :dirty, :channeling, :scratches, :tape_residue, :rusty, :broken, :peeling,
      :splice_damage, :tearing, :spoking, :perforation_damage, :warp, :water_damage, :color_fade,
      :lacquer_treated, :dusty, :replasticized, :not_on_core_or_reel, :poor_wind, :missing_footage, :miscellaneous
  ]
  CONDITION_BOOLEAN_FIELDS = [:lacquer_treated, :dusty, :replasticized, :not_on_core_or_reel, :poor_wind]
  CONDITION_FIELDS_HUMANIZED = { ad_strip: "AD Strip" }

  # Merge all of the humanized field maps together so the search space is singular
  HUMANIZED_SYMBOLS = GENERATION_FIELDS_HUMANIZED.merge(VERSION_FIELDS_HUMANIZED.merge(BASE_FIELDS_HUMANIZED.merge(
      STOCK_FIELDS_HUMANIZED.merge(PICTURE_TYPE_FIELDS_HUMANIZED.merge(COLOR_FIELDS_HUMANIZED.merge(
          ASPECT_RATIO_FIELDS_HUMANIZED.merge(SOUND_FORMAT_FIELDS_HUMANIZED.merge(
              SOUND_CONTENT_FIELDS_HUMANIZED.merge(SOUND_CONFIGURATION_FIELDS_HUMANIZED.merge(CONDITION_FIELDS_HUMANIZED))
              ))))))))

	def media_types
		MEDIA_TYPES
	end

	def media_type_mediums
		MEDIA_TYPE_MEDIUMS
	end

	def current_workflow_status
		workflow_statuses.last
	end


	def workflow
		current_workflow_status&.workflow_type
	end

	def group_identifier
		t_id = titles.first.id
		"FDB#{"%08d" % t_id}"
	end

	# tests if the physical object is currently on IULMIA staff workflow space
	def onsite?
		current_workflow_status.workflow_type
	end

	def in_transit_from_storage?
		current_workflow_status.status_name == WorkflowStatus::PULL_REQUESTED
	end

	def packed?
		current_workflow_status.status_name == WorkflowStatus::IN_CAGE
	end

	# need this for the ajax form that creates new titles for this physical object
	def title_text

	end
	def no_collection
		self.collection.blank?
	end

	# where (IN ALF!!!) the PO is currently stored
	def storage_location
		ingested = WorkflowStatus.where(physical_object_id: id, status_name: WorkflowStatus::IN_STORAGE_INGESTED).size > 0
		if awaiting_freezer?
			return WorkflowStatus::AWAITING_FREEZER
		elsif in_freezer?
			return WorkflowStatus::IN_FREEZER
		elsif ingested
			return WorkflowStatus::IN_STORAGE_INGESTED
		else
			return WorkflowStatus::IN_STORAGE_AWAITING_INGEST
		end
	end


	# title_text, series_title_text, and collection_text are all necesasary for javascript autocomplete on these fields for
	# forms. They provide a display value for the title/series/collection but are never set directly - the id of the model record
	# is set and passed as the param for assignment
	def titles_text
		#self.title.title_text if self.title
		self.titles.collect{ |t| t.title_text }.join(", ") unless self.titles.nil?
	end

	def series_title_text
		self.title.series.title if self.title && self.title.series
	end

	def dates_text
		self.physical_object_dates.collect{ |d| "#{d.date} [#{d.type}]" }.join(', ') unless self.physical_object_dates.nil?	end

	def series_id
		self.title.series.id if self.title && self.title.series
  end

	def collection_text
		self.collection.name if self.collection
  end

  def generations_text
  end

  def belongs_to_title?(title_id)
    PhysicalObjectTitle.where(physical_object_id: id, title_id: title_id).size > 0
  end

	# checks to see if any other physical objects that belong to this objects active component group are not at the same point in the workflow
	# returns either false if there are no other physical objects in this objects active component group that are at different workflow statuses
	# or an array of those physical objects at different workflow statuses
	def waiting_active_component_group_members?
		if active_component_group.nil?
			false
		else
			list = active_component_group.physical_objects.select{ |p| p != self && self.current_workflow_status != p.current_workflow_status }
			return list.size == 0 ? false : list
		end
	end

	# checks whether there are any other physical objects in this objects active component group who are at the same place in the workflow
	def same_active_component_group_members?
		if active_component_group.nil?
			false
		else
			li = active_component_group.physical_objects.select{ |p| p != self && self.current_workflow_status == p.current_workflow_status }
			return li.size == 0 ? false : li
		end
	end

	# duration is input as hh:mm:ss but stored as seconds
	def duration=(time)
    if time.blank?
      super(nil)
    else
      super(time.split(':').map { |a| a.to_i }.inject(0) { |a, b| a * 60 + b})
    end
  end

  # returns true if the specified text is formated as h:mm:ss where h, mm, and ss are integer values
  def valid_duration?(text)
    ! /^[0-9]+:[0-9]{2,}:[0-9]{2,}$/.match(text).nil?
  end

  # returns true of the text is formatted as "x of y" where x and y are either integers or a '?'
  def valid_reel_number?(text)
    ! /^[0-9\?]+ of [0-9\?]$/.match(text).nil?
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


  def test_after_create
    puts "\n\nAfter Creation: #{self.created_at}\n\n"
  end

  def test_after_validation
    puts "\n\nAfter Validation: #{self.created_at}\n\n"
  end

  def test_before_save
    puts "\n\nBefore Save: #{self.created_at}\n\n"
  end

  def test_after_save
    puts "\n\nAfter Save: #{self.created_at}\n\n"
	end

	def to_xml(options)
		xml = options[:builder]
		xml.physicalObject do
			xml.filmdbId id
			xml.groupIdentifier group_identifier
			xml.mdpiBarcode mdpi_barcode
			xml.iucatBarcode iu_barcode
			xml.format medium
			xml.unit unit.abbreviation
			xml.title titles.collect { |t| t.title_text }.join(", ")
			xml.alternativeTitle alternative_title unless alternative_title.nil?
			xml.collectionName collection&.name
			xml.accompanyingDocumentation accompanying_documentation
			xml.accompanyingDocumentationLocation accompanying_documentation_location
			xml.gauge gauge
			xml.reelNumber reel_number
			xml.canSize can_size
			xml.footage footage
			xml.duration duration
			xml.formatNotes format_notes
			xml.frameRate frame_rate
			xml.closeCaption close_caption
			xml.sound sound
			xml.missingFootage missing_footage
			xml.conditionRating condition_rating
			xml.conditionNotes condition_notes
			xml.researchValue research_value
			xml.researchValueNotes research_value_notes
			xml.conservationActions conservation_actions
			xml.multipleItemsInCan multiple_items_in_can
			xml.miscellaneous miscellaneous
			xml.captionedOrSubtitled captioned
			xml.captionedOrSubtitleNotes captions_or_subtitles_notes
			xml.anamorphic anamorphic
			xml.trackCount track_count
			xml.returnTo storage_location
			if active_component_group != nil
				xml.resolution active_component_group.scan_resolution
			end
			if active_component_group != nil
				xml.clean active_component_group.clean
			end
			xml.originalIdentifiers do
				physical_object_original_identifiers.each do |oi|
					xml.identifier oi.identifier
				end
			end
			xml.editions do
				xml.firstEdition first_edition
				xml.secondEdition second_edition
				xml.thirdEdition third_edition
				xml.fourthEdition fourth_edition
				xml.abridged abridged
				xml.short short
				xml.long long
				xml.sample sample
				xml.preview preview
				xml.revised revised
				xml.original version_original
				xml.captioned captioned
				xml.excerpt excerpt
				xml.catholic catholic
				xml.domestic domestic
				xml.english english
				xml.television television
				xml.xRated x_rated
			end
			xml.generations do
				xml.projectionPrint generation_projection_print
				xml.aRoll generation_a_roll
				xml.bRoll generation_b_roll
				xml.cRoll generation_c_roll
				xml.dRoll generation_d_roll
				xml.answerPrint generation_answer_print
				xml.composite generation_composite
				xml.duplicate generation_duplicate
				xml.edited generation_edited
				xml.fineGrainMaster generation_fine_grain_master
				xml.intermediate generation_intermediate
				xml.kinescope generation_kinescope
				xml.magneticTrack generation_magnetic_track
				xml.mezzanine generation_mezzanine
				xml.negative generation_negative
				xml.opticalSoundTrack generation_optical_sound_track
				xml.original generation_original
				xml.outsAndTrims generation_outs_and_trims
				xml.positive generation_positive
				xml.reversal generation_reversal
				xml.separationMaster generation_separation_master
				xml.workPrint generation_work_print
				xml.mixed generation_mixed
				xml.originalCamera generation_original_camera
				xml.master generation_master
			end
			xml.bases do
				xml.acetate base_acetate
				xml.polyester base_polyester
				xml.nitrate base_nitrate
				xml.mixed base_mixed
			end
			xml.stocks do
				xml.agfa stock_agfa
				xml.ansco stock_ansco
				xml.dupont stock_dupont
				xml.orwo stock_orwo
				xml.fuji stock_fuji
				xml.gevaert stock_gevaert
				xml.kodak stock_kodak
				xml.ferrania stock_ferrania
				xml.mixed stock_mixed
			end
			xml.pictureTypes do
				xml.notApplicable picture_not_applicable
				xml.silentPicture picture_silent_picture
				xml.mosPicture picture_mos_picture
				xml.compositePicture picture_composite_picture
				xml.intertitlesOnly picture_intertitles_only
				xml.creditsOnly picture_credits_only
				xml.pictureEffects picture_picture_effects
				xml.pictureOuttakes picture_picture_outtakes
				xml.kinescope picture_kinescope
			end
			xml.dates do
				physical_object_dates.each do |pod|
					xml.date do
						xml.value pod.date
						xml.type pod.controlled_vocabulary.value
					end
				end
			end
			xml.color do
				xml.blackAndWhiteToned color_bw_bw_toned
				xml.blackAndWhiteTinted color_bw_bw_tinted
				xml.ektachrome color_bw_color_ektachrome
				xml.kodachrome color_bw_color_kodachrome
				xml.technicolor color_bw_color_technicolor
				xml.ansochrome color_bw_color_ansochrome
				xml.eco color_bw_color_eco
				xml.eastman color_bw_color_eastman
				xml.color color_bw_color_color
				xml.blackAndWhite color_bw_bw_black_and_white
				xml.handColoring color_bw_bw_hand_coloring
				xml.stencilColoring  color_bw_bw_stencil_coloring
			end
			xml.aspectRatios do
				xml.ratio_1_33_1 aspect_ratio_1_33_1
				xml.ratio_1_37_1 aspect_ratio_1_37_1
				xml.ratio_1_66_1 aspect_ratio_1_66_1
				xml.ratio_1_85_1 aspect_ratio_1_85_1
				xml.ratio_2_35_1 aspect_ratio_2_35_1
				xml.ratio_2_39_1 aspect_ratio_2_39_1
				xml.ratio_2_59_1 aspect_ratio_2_59_1
			end
			xml.soundFormats do
				xml.optical sound_format_optical
				xml.opticalVariableArea sound_format_optical_variable_area
				xml.opticalVariableDensity sound_format_optical_variable_density
				xml.magnetic sound_format_magnetic
				xml.mixed sound_format_mixed
				xml.digitalSdds sound_format_digital_sdds
				xml.digitalDts sound_format_digital_dts
				xml.dolbyDigital sound_format_digital_dolby_digital
				xml.soundOnSeparateMedia sound_format_sound_on_separate_media
			end
			xml.soundContent do
				xml.musicTrack sound_content_music_track
				xml.effectsTrack sound_content_effects_track
				xml.dialog sound_content_dialog
				xml.compositeTrack sound_content_composite_track
				xml.outtakes sound_content_outtakes
			end
			xml.soundConfigurations do
				xml.mono sound_configuration_mono
				xml.stereo sound_configuration_stereo
				xml.surround sound_configuration_surround
				xml.multiTrack sound_configuration_multi_track
				xml.dual sound_configuration_dual_mono
			end

			xml.languages do
				languages.each do |l|
					xml.language(l.language, type: l.language_type)
				end
			end
			xml.conditions do
				xml.mold mold
				xml.adStrip ad_strip
				value_conditions.each do |vc|
					xml.condition do
						xml.type vc.condition_type
						xml.value vc.value
						xml.comment vc.comment
					end
				end
				boolean_conditions.each do |bc|
					xml.condition do
						xml.type bc.condition_type
						xml.comment bc.comment
					end
				end
			end
		end
	end

end
