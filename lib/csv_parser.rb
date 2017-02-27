# noinspection ALL
class CsvParser
  require 'csv'
  require 'manual_roll_back_exception'

  attr_accessor :percent_complete

  # the column headers that spreadsheets should contain - only the 5 metadata fields required to create a physical object
  # are required in the spreadsheet headers, but if optional fields are supplied, they must conform to this vocabulary
  COLUMN_HEADERS = [
      'Title', 'Duration', 'Series Name', 'Media Type', 'Medium', 'Unit', 'Collection', 'Current Location', 'IU Barcode', 'MDPI Barcode', 'IUCat Title No.',
      'Version', 'Gauge', 'Generation', 'Original Identifier', 'Reel Number', 'Multiple Items in Can', 'Can Size', 'Footage', 'Edge Code Date', 'Base',
      'Stock', 'Picture Type', 'Frame Rate', 'Color', 'Aspect Ratio', 'Sound', 'Captions or Subtitles', 'Captions or Subtitles Notes', 'Sound Format Type', 'Sound Content Type',
      'Sound Configuration', 'Dialog Language', 'Captions or Subtitles Language', 'Format Notes', 'Overall Condition', 'Research Value', 'Overall Condition Notes', 'AD Strip',
      'Shrinkage', 'Mold', 'Condition Type', 'Missing Footage', 'Miscellaneous Condition Type', 'Conservation Actions', 'Creator',
      'Publisher', 'Genre', 'Form', 'Subject', 'Alternative Title', 'Series Production Number', 'Series Part', 'Accompanying Documentation',
      'Created By', 'Email Address', 'Research Value Notes', 'Date Created', 'Location', 'Date', 'Accompanying Documentation Location', 'Title Summary'
  ]
  # Constant integer values used to link to the index in COLUMN_HEADERS where the specified string is indexed
  TITLE, DURATION, SERIES_NAME, MEDIA_TYPE, MEDIUM, UNIT, COLLECTION, CURRENT_LOCATION, IU_BARCODE, MDPI_BARCODE, IUCAT_TITLE_NO = 0,1,2,3,4,5,6,7,8,9,10
  VERSION, GAUGE, GENERATION, ORIGINAL_IDENTIFIER, REEL_NUMBER, MULTIPLE_ITEMS_IN_CAN, CAN_SIZE, FOOTAGE, EDGE_CODE_DATE, BASE = 11,12,13,14,15,16,17,18,19,20
  STOCK, PICTURE_TYPE, FRAME_RATE, COLOR, ASPECT_RATIO, SOUND, CAPTIONS_OR_SUBTITLES, CAPTIONS_OR_SUBTITLES_NOTES, SOUND_FORMAT_TYPE, SOUND_CONTENT_TYPE = 21,22,23,24,25,26,27,28,29,30
  SOUND_CONFIGURATION, DIALOG_LANGUAGE, CAPTIONS_OR_SUBTITLES_LANGUAGE, FORMAT_NOTES, OVERALL_CONDITION, RESEARCH_VALUE ,OVERALL_CONDITION_NOTES, AD_STRIP = 31,32,33,34,35,36,37,38
  SHRINKAGE, MOLD, CONDITION_TYPE, MISSING_FOOTAGE, MISCELLANEOUS_CONDITION_TYPE, CONSERVATION_ACTIONS, CREATOR = 39,40,41,42,43,44,45
  PUBLISHER, GENRE, FORM, SUBJECT, ALTERNATIVE_TITLE, SERIES_PRODUCTION_NUMBER, SERIES_PART, ACCOMPANYING_DOCUMENTATION = 46,47,48,49,50,51,52,53
  CREATED_BY, EMAIL_ADDRESS, RESEARCH_VALUE_NOTES, DATE_CREATED, LOCATION, DATE, ACCOMPANYING_DOCUMENTATION_LOCATION, TITLE_SUMMARY = 54,55,56,57,58,59,60,61

  # hash mapping a column header to its physical object assignment operand using send() - only plain text fields that require no validation can be set this way
  HEADERS_TO_ASSIGNER = {
      COLUMN_HEADERS[IUCAT_TITLE_NO] => :title_control_number=, COLUMN_HEADERS[ALTERNATIVE_TITLE] => :alternative_title=,
      COLUMN_HEADERS[EDGE_CODE_DATE] => :edge_code=, COLUMN_HEADERS[CAPTIONS_OR_SUBTITLES_NOTES] => :captions_or_subtitles_notes=,
      COLUMN_HEADERS[MISSING_FOOTAGE] => :missing_footage=, COLUMN_HEADERS[MISCELLANEOUS_CONDITION_TYPE] => :miscellaneous=,
      COLUMN_HEADERS[OVERALL_CONDITION_NOTES] => :condition_notes=, COLUMN_HEADERS[CONSERVATION_ACTIONS] => :conservation_actions=,
      COLUMN_HEADERS[SERIES_PART] => :series_part=, COLUMN_HEADERS[SERIES_PRODUCTION_NUMBER] => :series_production_number=,
      COLUMN_HEADERS[MDPI_BARCODE] => :mdpi_barcode=, COLUMN_HEADERS[IU_BARCODE] => :iu_barcode=, COLUMN_HEADERS[FORMAT_NOTES] => :format_notes=,
      COLUMN_HEADERS[RESEARCH_VALUE_NOTES] => :research_value_notes=, COLUMN_HEADERS[ACCOMPANYING_DOCUMENTATION_LOCATION] => :accompanying_documentation_location=,
      COLUMN_HEADERS[ORIGINAL_IDENTIFIER] => :item_original_identifier=
  }

  # regexes for parsing
  CONDITION_PATTERN = /([a-zA-z]+) \(([\d])\)/
  NAME_ROLE_PATTERN = /^([a-zA-Z ]+) \(([a-zA-z ]+)\)$/

  # Delimiter used in columns with multiple values present
  DELIMITER = ' ; '

  # special logger for parsing spreadsheets
  def self.logger
    @@logger ||= Logger.new("#{Rails.root}/log/spreadsheet_submission_logger.log")
  end
  @@mutex = Mutex.new

  def initialize(filepath, spreadsheet, spreadsheet_submission)
    @filepath = filepath.tempfile.path
    @spreadsheet = spreadsheet
    @spreadsheet_submission = spreadsheet_submission
  end

  def parse_csv
    @csv = CSV.read(@filepath, headers: false)
    parse_headers(@csv[0])
    if @parse_headers_msg.size > 0
      @spreadsheet_submission.update_attributes(failure_message: @parse_headers_msg, successful_submission: false, submission_progress: 100)
    else
      @cv = ControlledVocabulary.physical_object_cv
      # the error message that gets stored in the SpreadSheetSubmission if it fails parsing
      error_msg = ""
      # all physical objects created from the spreadsheet
      all_physical_objects = []
      begin
        PhysicalObject.transaction do
          # parsing spreadsheets is a two pass process. First pass makes sure that values in cells conform to the specification
          # marking each row as bad with a custom error message in the physical object if something erroneous is found. Since
          # ActiveRecord validation clears the errors map, we need to make this first pass before we attempt to save any records.
          # Only if all records pass this initial "validation" can we move on to actually attempting to persist
          # the Physical Objects in the database. We call save (instead of save!) to avoid the exception that would roll back
          # the whole transaction - so that we can process all physical objects to determine all rows that failed rather than
          # just the first row.
          @csv.each_with_index do |row, i|
            unless i == 0
              po = parse_physical_object(row)
              all_physical_objects << po
              if po.errors.any?
                error_msg << error_msg(i, po)
              end
            end
          end

          # if @error_msg has length > 0 something blew up... otherwise we can pass off to ActiveRecord validation to see
          # passes/fails Rails validation
          if error_msg.nil? || error_msg.length == 0
            all_physical_objects.each_with_index do |po, index|
              unless po.save
                error_msg << error_msg(index + 1, po)
              end
            end
          end
          if error_msg.length > 0
            raise ManualRollBackException
          else
            @spreadsheet_submission.update_attributes(successful_submission: true, submission_progress: 100)
            @spreadsheet.update_attributes(successful_upload: true)
          end
        end
      rescue Exception => error
        unless error.class == ManualRollBackException
          @em = error.message << "<br/>"
          error.backtrace.each do |line|
            @em << line << "<br/>"
          end
        end
        unless @em.blank?
          error_msg << @em.html_safe
        end
        @spreadsheet_submission.update_attributes(failure_message: error_msg, successful_submission: false, submission_progress: 100)
      end
    end
  end

  private
  def parse_headers(row)
    @headers = Hash.new
    @parse_headers_msg = ''
    # read all of the file's column headers
    row.each_with_index { |header, i|
      unless header.nil?
        @headers[header.strip] = i
      end
    }
    # examine the headers to make sure that title, media type, medium, unit and iu_barcode are presernt (minimum to create physical object)
    [COLUMN_HEADERS[TITLE], COLUMN_HEADERS[MEDIUM], COLUMN_HEADERS[MEDIA_TYPE], COLUMN_HEADERS[UNIT], COLUMN_HEADERS[IU_BARCODE]].each do |h|
      unless @headers.include?(h)
        @parse_headers_msg << parsed_header_message(h)
      end
    end

    # examine spreadsheet headers to make sure theybconform to vocabulary
    @headers.keys.each do |ch|
      if !COLUMN_HEADERS.include?(ch)
        @parse_headers_msg << parsed_header_message(ch)
      end
    end
    # make sure that every header is present in the spreadsheet
    COLUMN_HEADERS.each do |h|
      unless @headers.keys.include?(h)
        @parse_headers_msg <<  parsed_header_message(h)
      end
    end
  end

  # utility for formatting a string message about a bad column header
  def parsed_header_message(ch)
    "Missing or malformed <i>#{ch}</i> header<br/>"
  end

  # this method parses a single row in the spreadsheet trying to reconstitute a physical object - it creates association objects (title, series, etc) as well
  def parse_physical_object(row)
    # read all auto parse fields
    po = PhysicalObject.new(spreadsheet_id: @spreadsheet.id)
    HEADERS_TO_ASSIGNER.keys.each do |k|
      # not all attributes in a physical object may be present in the spreadsheet...
      po.send(HEADERS_TO_ASSIGNER[k], row[@headers[k]]) unless @headers[k].nil?
    end

    # date created
    d = Date.strptime(row[column_index DATE_CREATED], '%Y/%m/%d')
    po.created_at = d

    # manually parse the other values to ensure conformance to controlled vocabulary
    dur = row[column_index DURATION]
    unless dur.blank?
      if po.valid_duration?(dur)
        po.send(:duration=, dur)
      else
        po.errors.add(:duration, "Improperly formated duration value (h:mm:ss): #{dur}")
      end
    end


    media_type = row[column_index MEDIA_TYPE]
    if media_type.blank? || !po.media_types.include?(media_type)
      po.errors.add(:media_type, "Media Type blank or malformed: '#{media_type}'")
    else
      po.send(:media_type=, media_type)
      medium = row[column_index MEDIUM]
      if medium.blank? || ! po.media_type_mediums[media_type].include?(medium)
        po.errors.add(:medium, "Medium blank or malformed: '#{medium}'")
      else
        po.send(:medium=, medium)
      end
    end


    location = row[column_index CURRENT_LOCATION]
    set_value(:location, location, po)

    gauge = row[column_index GAUGE]
    set_value(:gauge, gauge, po)

    reel = row[column_index REEL_NUMBER]
    unless reel.blank?
      if /^[0-9\?]+ of [0-9\?]+$/.match(reel)
        po.send(:reel_number=, reel)
      else
        po.errors.add(:reel_number, "Invalid Reel Number format (x of y): #{reel}")
      end
    end

    miic = row[column_index MULTIPLE_ITEMS_IN_CAN]
    set_boolean_value(:multiple_items_in_can, miic, po)

    can = row[column_index CAN_SIZE]
    can = can.to_i rescue can    #can size has a 'Cartridge value so is represented as text'
    set_value(:can_size, can.to_s, po)

    footage = row[column_index FOOTAGE]
    unless footage.blank?
      po.send(:footage=, footage.to_i)
    end

    frame = row[column_index FRAME_RATE]
    set_value(:frame_rate, frame, po)

    sound = row[column_index SOUND]
    unless sound.blank?
      if @cv[:sound].collect { |x| x[0] }.include? sound
        set_value(:sound, sound, po)
      else
        po.errors.add(:sound, "Invalid Sound value: #{sound}")
      end
    end

    captioned = row[column_index CAPTIONS_OR_SUBTITLES]
    set_boolean_value(:close_caption, captioned, po)

    cr = row[column_index OVERALL_CONDITION]
    unless cr.blank?
      @cv[:condition_rating].collect { |x| x[0] }.each do |k|
        if k.include?(cr)
          po.send(:condition_rating=, k)
        end
      end
      if po.condition_rating.blank?
        po.errors.add(:condition_rating, "Invalid Overall Condition Rating: #{cr}")
      end
    end

    rv = row[column_index RESEARCH_VALUE]
    unless rv.blank?
      @cv[:research_value].collect { |x| x[0] }.each do |k|
        if k.include? (rv)
          po.send(:research_value=, k)
        end
      end
      if po.research_value.blank?
        po.errors.add(:research_value, "Invalid Research Value: #{rv}")
      end
    end

    ad = row[column_index AD_STRIP]
    set_value(:ad_strip, ad.to_s, po)

    shrink = row[column_index SHRINKAGE]
    unless shrink.blank?
      float = !!Float(shrink) rescue false
      if float
        po.send(:shrinkage=, float)
      end
    end

    mold = row[column_index MOLD]
    set_value(:mold, mold, po)

    # now parse all title data
    @title_cv = ControlledVocabulary.title_cv
    @title_date_cv = ControlledVocabulary.title_date_cv
    @title_genre_cv = ControlledVocabulary.title_genre_cv[:genre].collect { |x| x[0] }
    @title_form_cv = ControlledVocabulary.title_form_cv[:form].collect { |x| x[0] }
    title = Title.new(title_text: row[column_index TITLE])
    title.spreadsheet_id = @spreadsheet.id
    title_summary = row[column_index TITLE_SUMMARY]
    unless title_summary.blank?
      title.summary = title_summary
    end

    dates = row[column_index DATE].to_s
    unless dates.blank?
      dates.split(DELIMITER).each do |date|
        date_type = /^([0-9\/?~]+) \(([a-zA-Z ]+)\)$/
        date_only = /^([0-9\/?~]+)$/
        if date_type.match(date)
          matcher = date_type.match(date)
          d = matcher[1]
          type = matcher[2]
          if @title_date_cv[:date_type].collect { |x| x[0] }.include? type
            TitleDate.new(title_id: title.id, date: d, date_type: type).save
          else
            po.errors.add(:title_date, "Invalid date_type: #{type}")
          end
        elsif date_only.match(date)
          d = date_only.match(date)[1]
          title.title_dates << TitleDate.new(title_id: title.id, date: d, date_type: 'Unknown')
        else
          po.errors.add(:title_date, "Invalid date/date_type format: #{date}")
        end
      end
    end

    # title creators, publishers, form, genre, (subject - currently waiting on controlled vocab to implement) and location
    creator_values = row[column_index CREATOR]
    unless creator_values.blank?
      creator_values.split(DELIMITER).each do |val|
        matcher = NAME_ROLE_PATTERN.match(val)
        if matcher
          name = matcher[1]
          role = matcher[2]
          if @title_cv[:title_creator_role_type].collect { |x| x[0] }.include?(role)
            title.title_creators << TitleCreator.new(title_id: title.id, name: name, role: role)
          else
            po.errors.add(:title_creator, "Undefined Title Creator Role: #{role}")
          end
        else
          po.errors.add(:title_creator, "Malformed Title Creator: #{val}")
        end
      end
    end

    publisher_values = row[column_index PUBLISHER]
    unless publisher_values.blank?
      publisher_values.split(DELIMITER).each do |pv|
        matcher = NAME_ROLE_PATTERN.match(pv)
        if matcher
          name = matcher[1]
          role = matcher[2]
          if @title_cv[:title_publisher_role_type].collect { |x| x[0] }.include?(role)
            title.title_publishers << TitlePublisher.new(title_id: title.id, name: name, publisher_type: role)
          else
            po.errors.add(:title_publisher, "Undefined Title Publisher Role: #{role}")
          end
        else
          po.errors.add(:title_publisher, "Malformed Title Publisher: #{pv}")
        end
      end
    end

    form_values = row[column_index FORM]
    unless form_values.blank?
      form_values.split(DELIMITER).each do |fv|
        if @title_form_cv.include?(fv)
          title.title_forms << TitleForm.new(title_id: title.id, form: fv)
        else
          po.errors.add(:title_form, "Undefined Title Form: #{fv}")
        end
      end
    end

    genre_values = row[column_index GENRE]
    unless genre_values.blank?
      genre_values.split(DELIMITER).each do |gv|
        if @title_genre_cv.include?(gv)
          title.title_genres << TitleGenre.new(title_id: title.id, genre: gv)
        else
          po.errors.add(:title_genre, "Undefined Title Genre: #{gv}")
        end
      end
    end

    title_locs = row[column_index LOCATION]
    unless title_locs.blank?
      title_locs.split(DELIMITER).each do |tl|
        title.title_locations << TitleLocation.new(location: tl)
      end
    end

    # series data
    series = row[column_index SERIES_NAME].blank? ? nil : Series.new(title: row[column_index SERIES_NAME])
    unless series.nil?
      title.series = series
      series.spreadsheet_id = @spreadsheet.id
    end
    unless series.nil?
      series.save
    end
    title.save
    po.title = title

    unit = Unit.where(abbreviation: row[column_index UNIT]).first
    if unit.nil?
      po.errors.add(:unit, "Undefined unit: #{row[column_index UNIT]}")
    else
      po.unit = unit
      # collections are tied to a unit
      collection = row[column_index COLLECTION].blank? ? nil : Collection.where(name: row[column_index COLLECTION], unit_id: unit.id).first
      # a value in the COLLECTION cell but not matching an ActiveRecord instance means we must reject the spreadsheet because all
      # collections in spreadsheet must exist prior to ingest
      if row[column_index COLLECTION] && collection.nil?
        po.errors.add(:collection, "Undefined collection for #{unit.abbreviation}: #{row[column_index COLLECTION]}")
      else
        po.collection = collection
      end
    end

    email = row[column_index EMAIL_ADDRESS]
    name = row[column_index CREATED_BY]
    if (email && name)
      username = email.split('@')[0]
      user = User.where(username: username).first
      unless user
        user = User.new(username: username, email_address: email, first_name: name.split(' ')[0], last_name: name.split(' ')[1], active: false, created_in_spreadsheet: @spreadsheet.id)
        user.save
      end
      po.inventorier = user
      po.modifier = user
    elsif !(email.blank? && name.blank?)
      po.errors.add(:user, "User missing Created By or Email Address field")
    end

    # FIXME: this will change eventually to relational objects.
    acd = row[column_index ACCOMPANYING_DOCUMENTATION]
    unless acd.blank?
      po.send(:accompanying_documentation=, acd)
    end

    # version
    version_fields = row[column_index VERSION].blank? ? [] : row[column_index VERSION].split(DELIMITER)
    version_fields.each do |vf|
      field = vf.parameterize.underscore
      if PhysicalObject::VERSION_FIELDS.include?(field.to_sym)
        po.send((field << "=").to_sym, true)
      else
        # it could be 1st - 4th edition which don't 'map' easily from attribute name to humanized text
        case field
          when "1st_edition"
            po.send(:first_edition=, true)
          when "2nd_edition"
            po.send(:second_edition=, true)
          when "3rd_edition"
            po.send(:third_edition=, true)
          when "4th_edition"
            po.send(:fourth_edition=, true)
          when "original"
            po.send(:version_original=, true)
          else
            po.errors.add(:version, "Undefined version: #{vf}")
        end
      end
    end

    # generation
    gen_fields = row[column_index GENERATION].blank? ? [] : row[column_index GENERATION].split(DELIMITER)
    gen_fields.each do |gf|
      field = "generation #{gf}".parameterize.underscore
      if PhysicalObject::GENERATION_FIELDS.include?(field.to_sym)
        po.send((field << "=").to_sym, true)
      else
        po.errors.add(:generation, "Undefined generation: #{gf}")
      end
    end

    # base
    base_fields = row[column_index BASE].blank? ? [] : row[column_index BASE].split(DELIMITER)
    base_fields.each do |bf|
      field = "base #{bf}".parameterize.underscore
      if PhysicalObject::BASE_FIELDS.include?(field.to_sym)
        po.send((field << "=").to_sym, true)
      else
        po.errors.add(:base, "Undefined base: #{bf}")
      end
    end

    # stock
    stock_fields = row[column_index STOCK].blank? ? [] : row[column_index STOCK].split(DELIMITER)
    stock_fields.each do |sf|
      field = "stock #{sf}".parameterize.underscore
      if PhysicalObject::STOCK_FIELDS.include?(field.to_sym)
        po.send((field << "=").to_sym, true)
      else
        po.errors.add(:stock, "Undefined stock: #{sf}")
      end
    end

    #picture type
    picture_fields = row[column_index PICTURE_TYPE].blank? ? [] : row[column_index PICTURE_TYPE].split(DELIMITER)
    picture_fields.each do |pf|
      field = "picture #{pf}".parameterize.underscore
      if (PhysicalObject::PICTURE_TYPE_FIELDS.include?(field.to_sym))
        po.send((field << "=").to_sym, true)
      else
        po.errors.add(:picture_type, "Undefined picture type: #{pf}")
      end
    end

    # color
    color_fields = row[column_index COLOR].blank? ? [] : row[column_index COLOR].split(DELIMITER)
    color_fields.each do |cf|
      color_field = "color bw color #{cf}".parameterize.underscore
      bw_field = "color bw bw #{cf}".parameterize.underscore
      if (PhysicalObject::COLOR_BW_FIELDS.include?(bw_field.to_sym))
        po.send((bw_field << '=').to_sym, true)
      elsif (PhysicalObject::COLOR_COLOR_FIELDS.include?(color_field.to_sym))
        po.send((color_field << '=').to_sym, true)
      else
        po.errors.add(:color_fields, "Undefined Color: #{cf}")
      end
    end

    # aspect ratio
    aspect_fields = row[column_index ASPECT_RATIO].blank? ? [] : row[column_index ASPECT_RATIO].split(DELIMITER)
    aspect_fields.each do |af|
      case af
        when "1:33:1"
          po.send(:aspect_ratio_1_33_1=, true)
        when "1:37:1"
          po.send(:aspect_ratio_1_37_1=, true)
        when "1:66:1"
          po.send(:aspect_ratio_1_66_1=, true)
        when "1:85:1"
          po.send(:aspect_ratio_1_85_1=, true)
        when "2:35:1"
          po.send(:aspect_ratio_2_35_1=, true)
        when "2:39:1"
          po.send(:aspect_ratio_2_39_1=, true)
        when "2:59:1"
          po.send(:aspect_ratio_2_59_1=, true)
        else
          puts "Bad aspect ratio: #{af}"
          po.errors.add(:aspect_ratio, "Undefined aspect ratio: #{af}")
      end
    end

    # sound format type
    format_fields = row[column_index SOUND_FORMAT_TYPE].blank? ? [] : row[column_index SOUND_FORMAT_TYPE].split(DELIMITER)
    format_fields.each do |ff|
      field = "sound format #{ff}".parameterize.underscore
      if PhysicalObject::SOUND_FORMAT_FIELDS.include?(field.to_sym)
        po.send((field << "=").to_sym, true)
      else
        po.errors.add(:sound_format_type, "Undefined sound format: #{ff}")
      end
    end

    # sound content type
    content_fields = row[column_index SOUND_CONTENT_TYPE].blank? ? [] : row[column_index SOUND_CONTENT_TYPE].split(DELIMITER)
    content_fields.each do |cf|
      field = "sound content #{cf}".parameterize.underscore
      if PhysicalObject::SOUND_CONTENT_FIELDS.include?(field.to_sym)
        po.send((field << "=").to_sym, true)
      else
        po.errors.add(:sound_content_type, "Undefined sound content type: #{cf}")
      end
    end

    # sound configuration
    config_fields = row[column_index SOUND_CONFIGURATION].blank? ? [] : row[column_index SOUND_CONFIGURATION].split(DELIMITER)
    config_fields.each do |cf|
      field = "sound configuration #{cf}".parameterize.underscore
      if PhysicalObject::SOUND_CONFIGURATION_FIELDS.include?(field.to_sym)
        po.send((field << "=").to_sym, true)
      else
        po.errors.add(:sound_configuration, "Undefined sound configuration: #{cf}")
      end
    end

    # language-dialog fields
    lang_fields = row[column_index DIALOG_LANGUAGE].blank? ? [] : row[column_index DIALOG_LANGUAGE].split(DELIMITER)
    lang_fields.each do |lf|
      field = "language #{lf}".parameterize.underscore
      if PhysicalObject::LANGUAGE_FIELDS.include?(field.to_sym)
        po.send((field << "=").to_sym, true)
      else
        po.errors.add(:dialog_language, "Undefined dialog language: #{lf}")
      end
    end

    # TODO: implement language-captions/subtitles parsing once fields exist in physical objects

    # ad strip, mold, and shrinkage have their own columns
    ad = row[column_index AD_STRIP].blank?
    unless ad.blank?
      po.send(:ad_strip=, ad)
    end
    mold = row[column_index MOLD].blank? ? "" : row[column_index MOLD].strip
    if mold.length > 0
      po.send(:mold=, mold)
    end
    shrink = row[column_index SHRINKAGE]
    unless shrink.blank?
      po.send(:shrinkage=, shrink)
    end

    # condition type fields with value ranges or booleans
    condition_fields = row[column_index CONDITION_TYPE].blank? ? [] : row[column_index CONDITION_TYPE].split(DELIMITER)
    cv = ControlledVocabulary.physical_object_cv
    val_conditions = cv[:value_condition].collect { |x| x[0]}
    bool_conditions = cv[:boolean_condition].collect { |x| x[0]}
    condition_fields.each do |cf|
      if bool_conditions.include?(cf)
        po.boolean_conditions << BooleanCondition.new(condition_type: cf, physical_object_id: po.id)
      else
        # some condition types have a range value (1-5), strip this off before matching against PhysicalObject::CONDITION_FIELDS
        pattern = /([a-zA-Z ]+) \(([1-5]{1})\)/
        matcher = pattern.match(cf)
        if matcher && val_conditions.include?(matcher[1])
          po.value_conditions << ValueCondition.new(condition_type: matcher[1], value: cv[:condition_rating][matcher[2].to_i - 1][0], physical_object_id: po.id)
        else
          po.errors.add(:condition, "Undefined or malformed condition type: #{cf}")
        end
      end
    end
    po
  end

  def set_value(attr_symbol, val, po)
    unless val.blank?
      if @cv[attr_symbol].collect { |x| x[0] }.include? val
        po.send((attr_symbol.to_s << "=").to_sym, val)
      else
        po.errors.add(attr_symbol, "Invalid #{attr_symbol.to_s.humanize} value: #{val}")
      end
    end
  end

  def set_boolean_value(attr_symbol, val, po)
    po.send((attr_symbol.to_s << "=").to_sym, ! val.blank?)
  end

  def error_msg(row, physical_object)
    msg = "<div>Physical Object at row #{row} has the following problem(s):</div><ul>".html_safe
    physical_object.errors.keys.each do |k|
      attr = k.to_s.humanize
      problems = physical_object.errors[k].map(&:inspect).join(', ')
      msg << "<li>#{attr}: #{problems}</li>".html_safe
    end
    msg << "</ul>".html_safe
  end

  # feed this method a column constant (STOCK, BASE, TITLE, etc) and it returns the column index of the current spreadsheet
  # where that value resides
  def column_index(column_constant)
    @headers[COLUMN_HEADERS[column_constant]]
  end
end