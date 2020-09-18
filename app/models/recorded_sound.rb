class RecordedSound < ApplicationRecord
  acts_as :physical_object
  validates :iu_barcode, iu_barcode: true
  validates :mdpi_barcode, mdpi_barcode: true
  validates :gauge, presence: true

  NESTED_ATTRIBUTES = [:value_conditions_attributes, :boolean_conditions_attributes, :languages_attributes,
                       :physical_object_original_identifiers_attributes, :physical_object_dates_attributes]
  GAUGE_VALUES = ControlledVocabulary.where(model_type: 'Recorded Sound', model_attribute: ':gauge').pluck(:value)
  SIZE_VALUES = ControlledVocabulary.physical_object_cv('Recorded Sound')[:size].collect{|r| r[0]}
  STOCK_VALUES = ControlledVocabulary.physical_object_cv('Recorded Sound')[:stock].collect{|r| r[0]}
  PLAYBACK_SPEEDS = ControlledVocabulary.physical_object_cv('Recorded Sound')[:playback_speed].collect { |r| r[0] }

  VERSION_FIELDS = [:version_first_edition, :version_second_edition, :version_third_edition, :version_fourth_edition,
                    :version_abridged,  :version_anniversary, :version_domestic, :version_english, :version_excerpt, :version_long,
                    :version_original, :version_reissue, :version_revised, :version_sample, :version_short,
                    :version_x_rated]
  VERSION_FIELDS_HUMANIZED = {
      version_first_edition: "1st Edition", second_edition: "2nd Edition", third_edition: "3rd Edition", fourth_edition: "4th Edition",
      version_abridged: 'Abridged', version_anniversary: 'Anniversary', version_domestic: 'Domestic', version_english: 'English',
      version_excerpt:"Excerpt", version_long: "Long", version_original: "Original", version_reissue: "Reissue",
      version_revised: "Revised", version_sample: "Sample", version_short: "Short", x_rated: "X-rated"
  }
  GENERATION_FIELDS = [:generation_copy_access, :generation_dub, :generation_duplicate, :generation_intermediate,
                       :generation_master, :generation_master_distribution, :generation_master_production,
                       :generation_off_air_recording, :generation_original_recording, :generation_preservation,
                       :generation_work_tape, :generation_other]
  GENERATION_FIELDS_HUMANIZED = {
      :generation_copy_access => "Copy: Access", :generation_dub => "Dub", :generation_duplicate => "Duplicate",
      :generation_intermediate => "Intermediate", :generation_master => "Master",
      :generation_master_distribution => "Master: Distribution", :generation_master_production => "Master: Production",
      :generation_off_air_recording => "Off Air Recording", :generation_original_recording => "Original Recording",
      :generation_preservation => "Preservation", :generation_work_tape => "Work Tapes", :generation_other => "Other"
  }

  # Is this necessary? base is a text field for RecordedSound objects but Video is the same and has this declaration
  BASE_FIELDS =[:base_acetate, :base_aluminum, :base_cardboard, :base_glass, :base_plaster, :base_polyester,
                :base_shellac, :base_steel, :base_vinyl, :base_wax]
  BASE_FIELDS_HUMANIZED = {
      base_acetate: "Acetate", base_aluminum: "Aluminum", base_cardboard: "Cardboard", base_glass: "Glass",
      base_plaster: "Plaster", base_polyester: "Polyester", base_shellac: "Shellac", base_steel: "Steel",
      base_vinyl: "Vinyl", base_wax: "Wax"
  }

  SOUND_CONTENT_FIELDS = [:sound_content_type_composite_track, :sound_content_type_dialog, :sound_content_type_effects_track,
                           :sound_content_type_music_track, :sound_content_type_outtakes]
  SOUND_CONTENT_FIELDS_HUMANIZED = {
      :sound_content_type_composite_track => "Composite track", :sound_content_type_dialog => "Dialog", :sound_content_type_effects_track => "Effects track",
      :sound_content_type_music_track => "Music track", :sound_content_type_outtakes => "Outtakes"
  }

  SOUND_CONFIGURATION_FIELDS = [:sound_configuration_dual_mono, :sound_configuration_mono, :sound_configuration_stereo,
                                :sound_configuration_surround, :sound_configuration_unknown, :sound_configuration_other]
  SOUND_CONFIGURATION_FIELDS_HUMANIZED = {
      :sound_configuration_dual_mono => "Dual Mono", :sound_configuration_mono => "Mono", :sound_configuration_stereo => "Stereo",
      :sound_configuration_surround => "Surround", :sound_configuration_unknown => "Unknown", :sound_configuration_other => "Other"
  }

  HUMANIZED_SYMBOLS = GENERATION_FIELDS_HUMANIZED.merge(VERSION_FIELDS_HUMANIZED.merge(BASE_FIELDS_HUMANIZED.merge(
      SOUND_CONTENT_FIELDS_HUMANIZED.merge(SOUND_CONFIGURATION_FIELDS_HUMANIZED))))


  def initialize(args = {})
    super
    # !!!! IMPORTANT - how the nested_form gem and active-record_acts_as gem interact with form submission and params.require.permit
    # creates duplicate entries for PhysicalObjectOriginalIdentifiers, PhysicalObjectDates, Languages, RatedConditions, and
    # BooleanConditions. The above super call ends up ALSO calling the initializer for PhysicalObjects which holds the
    # actual associations for these objects. They get created correctly. However, I think that when each of these is passed
    # through self.send() below, this results in a SECOND call to creating that metadata on the underlying physical object.
    # This only appears to happen during create action on physical objects however, make sure to remove the keys for these
    # metadata fields BEFORE iterating through them for the Film attributes
    NESTED_ATTRIBUTES.each do |na|
      args.delete(na)
    end

    acting_as.media_type = 'Recorded Sound'
    if args.is_a? ActionController::Parameters
      args.each do |a|
        self.send(a.dup << "=", args[a])
      end
    elsif args.is_a? Hash
      args.keys.each do |k|
        self.send((k.to_s << "=").to_sym, args[k])
      end
    else
      raise "What is args?!?!?"
    end
  end

  def medium_name
    "#{gauge}"
  end

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
