# this is the new one - not yet being used
module SpreadsheetHelper
  require 'rubygems'
  require 'roo'

  # the column headers that spreadsheets COULD contain - only the 5 metadata fields required to create a physical object
  # are required in the spreadsheet headers, but if optional fields are supplied, they must conform to this vocabulary
  COLUMN_HEADERS = [
      'Title', 'Duration', 'Series', 'Media Type', 'Medium', 'Unit', 'Collection', 'Current Location', 'IU Barcode',
      'MDPI Barcode', 'IUCAT Title No.', 'Version', 'Gauge', 'Generation', 'Original Identifier', 'Reel Number', 'Multiple Items In Can',
      'Can Size', 'Footage', 'Edge Code Date', 'Base', 'Stock', 'Picture Type', 'Frame Rate', 'Color', 'Aspect Ratio', 'Silent?',
      'Captions or Subtitles', 'Captions or Subtitles Notes', 'Sound Format Type', 'Sound Content Type', 'Sound Configuration',
      'Dialog Language', 'Captions or Subtitles Language', 'Format Notes', 'Overall Condition', 'Research', 'Overall Condition Notes',
      'AD Strip', 'Shrinkage', 'Mold', 'Condition Type', 'Missing Footage', 'Miscellaneous Condition Type', 'Conservation Actions',

      'Title Notes', 'Creator', 'Publisher', 'Genre', 'Form', 'Subject', 'Alternative Title', 'Series Production Number',
      # these fields were not mentioned in IUFD-76 spec but included because they are part of the physical object metadata
      'Series Part', 'Accompanying Documentation', 'First Name', 'Last Name', 'Inventoried By'
  ]

  TITLE, DURATION, SERIES, MEDIA_TYPE, MEDIUM, UNIT, COLLECTION, CURRENT_LOCATION, IU_BARCODE, MDPI_BARCODE, IUCAT_TITLE_NO = 0,1,2,3,4,5,6,7,8,9,10
  VERSION, GAUGE, GENERATION, ORIGINAL_IDENTIFIER, REEL_NUMBER, MULTIPLE_ITEMS_IN_CAN, CAN_SIZE, FOOTAGE, EDGE_CODE_DATE, BASE = 11,12,23,14,15,16,17,18,19,20
  STOCK, PICTURE_TYPE, FRAME_RATE, COLOR, ASPECT_RATIO, SILENT, CAPTIONS_OR_SUBTITLES, CAPTIONS_OR_SUBTITLES_NOTES, SOUND_FORMAT_TYPE, SOUND_CONTENT_TYPE = 21,22,23,24,25,26,27,28,29,30
  SOUND_CONFIGURATION, DIALOG_LANGUAGE, CAPTIONS_OR_SUBTITLES_LANGUAGE, FORMAT_NOTES, OVERALL_CONDITION, RESEARCH ,OVERALL_CONDITION_NOTES, AD_STRIP = 31,32,33,34,35,36,37,38
  SHRINKAGE, MOLD, CONDITION_TYPE, MISSING_FOOTAGE, MISCELLANEOUS_CONDITION_TYPE, CONSERVATION_ACTIONS, TITLE_NOTES, CREATOR = 39,40,41,42,43,44,45,46
  PUBLISHER, GENRE, FORM, SUBJECT, ALTERNATIVE_TITLE, SERIES_PRODUCTION_NUMBER, SERIES_PART, ACCOMPANYING_DOCUMENTATION = 47,48,49,50,51,52,53,54
  FIRST_NAME, LAST_NAME, INVENTORIED_BY = 55,56,57

  # hash mapping a column header to its physical object assignment operand using send()
  HEADERS_TO_ASSIGNER = {
      COLUMN_HEADERS[DURATION] => :duration=, COLUMN_HEADERS[MEDIA_TYPE] => :media_type=, COLUMN_HEADERS[MEDIUM] => :medium=,
      COLUMN_HEADERS[CURRENT_LOCATION] => :location=, COLUMN_HEADERS[IU_BARCODE] => :iu_barcode=, COLUMN_HEADERS[MDPI_BARCODE] => :mdpi_barcode=,
      COLUMN_HEADERS[IUCAT_TITLE_NO] => :title_control_number=, COLUMN_HEADERS[GAUGE] => :gauge=, COLUMN_HEADERS[REEL_NUMBER] => :reel_number=,
      COLUMN_HEADERS[MULTIPLE_ITEMS_IN_CAN] => :multiple_items_in_can=, COLUMN_HEADERS[CAN_SIZE] => :can_size=,
      COLUMN_HEADERS[FOOTAGE] => :footage=, COLUMN_HEADERS[EDGE_CODE_DATE] => :edge_code, COLUMN_HEADERS[FRAME_RATE] => :frame_rate=,
      COLUMN_HEADERS[SILENT] => :silent=, COLUMN_HEADERS[CAPTIONS_OR_SUBTITLES] => :captions_or_subtitles=,
      COLUMN_HEADERS[CAPTIONS_OR_SUBTITLES_NOTES] => :captions_or_subtitles_notes=, COLUMN_HEADERS[FORMAT_NOTES] => :format_notes=,
      COLUMN_HEADERS[OVERALL_CONDITION] => :overall_condition=, COLUMN_HEADERS[RESEARCH] => :research_value=,
      COLUMN_HEADERS[OVERALL_CONDITION_NOTES] => :condition_notes=, COLUMN_HEADERS[AD_STRIP] => :ad_strip=, COLUMN_HEADERS[SHRINKAGE] => :shrinkage=,
      COLUMN_HEADERS[MOLD] => :mold=, COLUMN_HEADERS[MISSING_FOOTAGE] => :missing_footage=, COLUMN_HEADERS[MISCELLANEOUS_CONDITION_TYPE] => :miscellaneous=,
      COLUMN_HEADERS[CONSERVATION_ACTIONS] => :conservation_actions=, COLUMN_HEADERS[ALTERNATIVE_TITLE] => :alternative_title=,
      COLUMN_HEADERS[ACCOMPANYING_DOCUMENTATION] => :accompanying_documentation=
  }

  CONDITION_PATTERN = /([a-zA-z]+) \(([\d])\)/

  # special logger for parsing spreadsheets
  def self.logger
    @@logger ||= Logger.new("#{Rails.root}/log/spreadsheet_submission_logger.log")
  end
  @@mutex = Mutex.new

  # parse a spreadsheet in the same thread of execution as the running process
  def parse_serial(upload, ss, sss)
    xlsx = Roo::Excelx.new(file.tempfile.path, file_warning: :ignore)
    xlsx.default_sheet = xlsx.sheets[0]
    parse_headers(xlsx)
    if @parse_headers_msg.size > 0
      sss.update_attributes(failure_message: @parse_headers_msg, successful_submission: false, submission_progress: 100)
    else
      @cv = ControlledVocabulary.physical_object_cv
      PhysicalObject.transaction do
        ((xlsx.first_row + 1)..(xlsx.last_row)).each do |row|
          po = validate_physical_object(xlsx.row(row), headers, ss)

          sss.update_attributes(submission_progress: ((row / xlsx.last_row).to_f * 50).to_i)
        end
      end
    end
  end

  # parse a spreadsheet in a separately executing thread
  def parse_parallel(upload, ss, sss)
    Thread.new {
      @@mutex.synchronize do
        parse_spreadsheet(upload, ss, sss)
      end
    }
  end

  private
  # examines the header portion of the upload spreadsheet to validate correct vocabulary
  def parse_headers(xlsx)
    @headers = Hash.new
    @parse_headers_msg = ''
    # read all of the file's column headers
    xlsx.row(1).each_with_index { |header, i|
      @headers[header] = i
    }
    # examine the headers to make sure that title, media type, medium, unit and iu_barcode are presernt (minimum to create physical object)
    [COLUMN_HEADERS[TITLE], COLUMN_HEADERS[MEDIUM], COLUMN_HEADERS[MEDIA_TYPE], COLUMN_HEADERS[UNIT], COLUMN_HEADERS[IU_BARCODE]].each do |h|
      unless @headers.include?(h)
        @parse_headers_msg << parsed_header_message(h)
      end
    end

    # examine headers to make sure that all present conform to vocabulary. and that there are no unknown column headers
    COLUMN_HEADERS.each do |ch|
      @parse_headers_msg << parsed_header_message(ch) if @headers[ch].nil?
    end
  end
  # utility for formatting a string message about a bad column header
  def parsed_header_message(ch)
    "Missing or malformed <i>#{ch}</i> header<br/>"
  end

  # this method parses a single row in the spreadsheet trying to reconstitute a physical object - it creates association objects (title, series, etc) as well
  def parse_physical_object(row, spreadsheet, spreadsheet_submission)
    # read all auto parse fields
    po = PhysicalObject.new
    HEADERS_TO_ASSIGNER.keys.each do |k|
      po.send HEADERS_TO_ASSIGNER[k], row[headers[k]]
    end

    # now parse all association data
    title = title.new(title_text: row[TITLE])
    title.spreadsheet_id = spreadsheet.id

    series = row[SERIES].blank? ? nil : Series.new(title: row[SERIES])
    unless series.nil?
      title.series = series
    end
    title.save
    series.save
    po.title = title

    unit = Unit.where(abbreviation: row[UNIT]).first
    if unit.nil?
      po.errors.add(:unit, "Undefined unit: #{row[UNIT]}")
    else
      po.unit = unit
    end

    collection = row[COLLECTION].blank? ? nil : Collection.where(name: row[COLLECTION]).first
    po.collection = collection

    # version
    version_fields = row[VERSION].split(' ; ')
    version_fields.each do |vf|
      field = vf.parameterize.underscore
      if PhysicalObject::VERSION_FIELDS.inlcude?(field.to_sym)
        po.send((field << "=").to_sym, true)
      else
        # it could be 1st - 4th edition
        case field
          when "1st_edition"
            po.send(:first_edition=, true)
          when "2nd_edition"
            po.send(:second_edition=, true)
          when "3rd_edition"
            po.send(:third_edition=, true)
          when "4th_edition"
            po.send(:fourth_edition=, true)
          else
            po.errors.add(:version, "Undefined version: #{vf}")
        end
      end
    end

    # generation



  end



end