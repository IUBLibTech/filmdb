class PhysicalObject < ActiveRecord::Base
	actable

	include ActiveModel::Validations
	include PhysicalObjectsHelper

	belongs_to :title
	belongs_to :spreadhsheet
	belongs_to :collection, autosave: true
	belongs_to :unit, autosave: true
	belongs_to :inventorier, class_name: "User", foreign_key: "inventoried_by", autosave: true
	belongs_to :modifier, class_name: "User", foreign_key: "modified_by", autosave: true
  belongs_to :cage_shelf
	belongs_to :active_component_group, class_name: 'ComponentGroup', foreign_key: 'component_group_id', autosave: true

	belongs_to :current_workflow_status, class_name: 'WorkflowStatus', foreign_key: 'current_workflow_status_id', autosave: true

	has_many :physical_object_old_barcodes
  has_many :component_group_physical_objects, dependent: :delete_all
  has_many :component_groups, through: :component_group_physical_objects
  has_many :physical_object_titles, dependent: :delete_all
  has_many :titles, through: :physical_object_titles
	has_many :series, through: :titles
	has_many :physical_object_dates
	has_many :physical_object_pull_requests
	has_many :pull_requests, through: :physical_object_pull_requests
	has_many :digiprovs

  validates :physical_object_titles, physical_object_titles: true
  validates :iu_barcode, iu_barcode: true
	validates :mdpi_barcode, mdpi_barcode: true
  validates :unit, presence: true
  #validates :media_type, presence: true
  validates :medium, presence: true
	# validates :gauge, presence: true

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
	#
	# FIXME: PhysicalObject.joins(:current_workflow_status).where("workflow_statuses.status_name = '#{WorkflowStatus::QUEUED_FOR_PULL_REQUEST}'")
	scope :where_current_workflow_status_is, lambda { |offset, limit, digitized, *status|
		# status values are concatenated into an array so if you want to pass an array of values (constants stored in other classes for instance) the passed array is wrapped in
		# an enclosing array. flattening it allows an array to be passed and leaves any params passed the 'normal' way untouched
		status = status.flatten

		sql = "SELECT physical_objects.* "+
			"FROM ( SELECT workflow_statuses.physical_object_id "+
			  "FROM (	SELECT physical_object_id, max(created_at) AS status FROM workflow_statuses GROUP BY physical_object_id) AS x "+
			    "INNER JOIN workflow_statuses on (workflow_statuses.physical_object_id = x.physical_object_id AND x.status = workflow_statuses.created_at) "+
			    "WHERE workflow_statuses.status_name in (#{status.map(&:inspect).join(', ')})) as y INNER JOIN physical_objects on physical_object_id = physical_objects.id #{(offset.nil? || limit.nil?) ? '' : "LIMIT #{limit} OFFSET #{offset}"}"+
				(digitized ? " WHERE physical_objects.digitized = true" : "")
		PhysicalObject.find_by_sql(sql)
	}

	# returns all physical whose workflow status matches any specified in *status - use WorkflowStatus status constants as values
	scope :count_where_current_workflow_status_is, lambda { |digitized, *status|

		# status values are concatenated into an array so if you want to pass an array of values (constants stored in other classes for instance) the passed array is wrapped in
		# an enclosing array. flattening it allows an array to be passed and leaves any params passed the 'normal' way untouched
		status = status.flatten

		sql = "SELECT count(*) "+
			"FROM ( SELECT workflow_statuses.physical_object_id "+
			"FROM (	SELECT physical_object_id, max(created_at) AS status FROM workflow_statuses GROUP BY physical_object_id) AS x "+
			"INNER JOIN workflow_statuses on (workflow_statuses.physical_object_id = x.physical_object_id AND x.status = workflow_statuses.created_at) "+
			"WHERE workflow_statuses.status_name in (#{status.map(&:inspect).join(', ')})) as y INNER JOIN physical_objects on physical_object_id = physical_objects.id"+
		(digitized ? " WHERE physical_objects.digitized = true" : "")
		ActiveRecord::Base::connection.execute(sql).first[0]
	}

	FREEZER_AD_STRIP_VALS = ControlledVocabulary.where(model_attribute: ':ad_strip').order('value DESC').limit(3).collect{ |cv| cv.value }

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
	NEW_MEDIUMS = ['Film', 'Video']

	def self.per_page
		100
	end

	def media_types
		MEDIA_TYPES
	end

	def media_type_mediums
		MEDIA_TYPE_MEDIUMS
	end

	# def current_workflow_status
	# 	workflow_statuses.last
	# end

	def current_location
		current_workflow_status.status_name
	end

	def previous_location
		workflow_statuses[workflow_statuses.size - 2]&.status_name
	end

	def workflow
		current_workflow_status&.workflow_type
	end

	def group_identifier
		titles.first.id
	end

	def scan_settings(component_group)
		cgpo = component_group_physical_objects.where(component_group_id: component_group.id).first
		{
				scan_resolution: cgpo.scan_resolution,
				color_space: cgpo.color_space,
				return_on_reel: cgpo.return_on_reel,
				clean: cgpo.clean
		}
	end

	# tests if the physical object is currently on IULMIA staff workflow space
	def onsite?
		current_workflow_status.workflow_type
	end

	def in_transit_from_storage?
		current_workflow_status.status_name == WorkflowStatus::PULL_REQUESTED
	end

	def in_storage?
		WorkflowStatus::STATUS_TYPES_TO_STATUSES['Storage'].include?(current_location)
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

	def who_requested
		pull_requests.last.requester
	end
	# where (IN ALF!!!) the PO should be stored
	def storage_location
		stats = workflow_statuses.where("status_name in (#{WorkflowStatus::STATUS_TYPES_TO_STATUSES['Storage'].map{ |s| "'#{s}'"}.join(',')})").order('created_at ASC')
		# anything with ad_strip > 2.0 must go to the freezer. If it's never been in the freezer if must go to awaiting freezer first for prep.
		# If it was last in the freezer, it should be returned to the freezer. Otherwise, the item is returned to its last storage location,
		# or ingested if it has yet to be put anywhere in storage
		if stats.size > 0
			if self.specific.ad_strip && FREEZER_AD_STRIP_VALS.include?(self.specific.ad_strip)
				(stats.last.status_name == WorkflowStatus::IN_FREEZER ? WorkflowStatus::IN_FREEZER : WorkflowStatus::AWAITING_FREEZER)
			else
				stats.last.status_name
			end
		else
			if self.specific.class == Film && self.specific.ad_strip && FREEZER_AD_STRIP_VALS.include?(self.specific.ad_strip)
				WorkflowStatus::AWAITING_FREEZER
			else
				WorkflowStatus::IN_STORAGE_INGESTED
			end
		end
	end

	def ingested_by_alf?
		last = workflow_statuses.where("status_name in (#{WorkflowStatus::STATUS_TYPES_TO_STATUSES['Storage'].map{ |s| "'#{s}'"}.join(',')})").order('created_at DESC').limit(1).first
		!last.nil? && last.status_name == WorkflowStatus::IN_STORAGE_INGESTED
	end

	def notify_alf
		ingested_by_alf? && (storage_location == WorkflowStatus::IN_FREEZER || storage_location == WorkflowStatus::AWAITING_FREEZER)
	end


	# title_text, series_title_text, and collection_text are all necessary for javascript autocomplete on these fields for
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
		self.humanize_boolean_fields(PhysicalObject::GENERATION_FIELDS)
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
      hh_mm_sec(super)
    end
	end

	def sound_only?
		return (medium == 'film' && (generation_separation_master || generation_optical_sound_track))
	end

	def current_scan_settings
		if active_component_group.nil?
			nil
		else
			component_group_physical_objects.where(component_group_id: active_component_group.id).first
		end
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

	def active_scan_settings
		if !active_component_group.nil?
			active_component_group.component_group_physical_objects.where(physical_object_id: self.id).first
		end
	end

	def estimated_duration_in_sec
		if footage.blank? || gauge.blank?
			0
		else
			(PhysicalObjectsHelper::GAUGES_TO_FRAMES_PER_FOOT[gauge] * footage) / 24
		end
	end

	# this method differs slightly from WorkflowStatus.in_active_workflow in that it tests against not being In Storage
	# TODO: WorkflowStatus needs to be updated (and reliant code modified) to
	def in_active_workflow?
		!active_component_group.nil? && !current_workflow_status.is_storage_status?
	end

	# There was a bug that allowed title records to be deleted while there were associated physical objects (leaving bad
	# entries in physical_object_titles) This method returns an array of EXISTING title ids for the physical object and,
	# additionally, deletes and physical_object_titles that references non-existent title ids
	def actual_title_ids
		# physical_object_titles.each do |pt|
    #   if pt.title.nil?
    #     pt.delete
    #   end
    # end
    physical_object_titles.pluck(:title_id)
  end

  # a helper for concatenating MEDIUM with additional medium specific info. For instance, a 35mm Film would be
  # displayed as 'Film 35mm'
  def format
    if [Film, Video].include?(self.specific.class)
      "#{self.medium} (#{self.specific.gauge})"
    else
      raise "Unsupported Medium... #{self.specific}"
    end
  end

	#
	def to_xml(options)
		xml = options[:builder]
		xml.physicalObject do
			xml.filmdbId id
			xml.titleId active_component_group.title.id
			xml.mdpiBarcode mdpi_barcode
			xml.iucatBarcode iu_barcode
			xml.redigitize (digitized || workflow_statuses.any?{|w| w.status_name == WorkflowStatus::SHIPPED_EXTERNALLY})
			xml.iucatTitleControlNumber title_control_number
			xml.catalogKey catalog_key
			xml.format medium
			xml.unit unit.abbreviation
			xml.title titles.collect{ |t| t.title_text }.join(', ')
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
			xml.notifyAlf notify_alf

			xml.resolution (sound_only? ? 'Audio only' : active_scan_settings.scan_resolution)
			xml.colorSpace active_scan_settings.color_space
			xml.clean active_scan_settings.clean
			xml.returnOnOriginalReel active_scan_settings.return_on_reel

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
				xml.other generation_other
			end
			xml.bases do
				xml.acetate base_acetate
				xml.polyester base_polyester
				xml.nitrate base_nitrate
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
				xml.agfa_gevaert stock_agfa_gevaert
				xml.three_m stock_3_m
				xml.pathe stock_pathe
				xml.unknown stock_unknown
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
				xml.titles picture_titles
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
				xml.anscochrome color_bw_color_anscochrome
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
				xml.ratio_1_36_1 aspect_ratio_1_36
				xml.ratio_1_18_1 aspect_ratio_1_18
			end
			xml.soundFormats do
				xml.optical sound_format_optical
				xml.opticalVariableArea sound_format_optical_variable_area
				xml.opticalVariableDensity sound_format_optical_variable_density
				xml.magnetic sound_format_magnetic
				xml.digitalSdds sound_format_digital_sdds
				xml.digitalDts sound_format_digital_dts
				xml.dolbyDigital sound_format_digital_dolby_digital
				xml.soundOnSeparateMedia sound_format_sound_on_separate_media
				xml.digitalDolbySR sound_format_digital_dolby_digital_sr
				xml.digitalDolbyA sound_format_digital_dolby_digital_a
			end
			xml.soundContent do
				xml.musicTrack sound_content_music_track
				xml.effectsTrack sound_content_effects_track
				xml.dialog sound_content_dialog
				xml.compositeTrack sound_content_composite_track
				xml.outtakes sound_content_outtakes
				xml.narration sound_content_narration
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
