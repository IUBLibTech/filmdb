module SpreadsheetsHelper
	require 'roo'

	# the column headers that spreadsheets should contain - in no particular order
	COLUMN_HEADERS = [
		'Location', 'Media Type', 'Item Barcode', 'Title', 'Copyright', 'Series Name', 'Series Production Number',
		'Series Part', 'Alternative Title', 'Item Original Identifier', 'Summary', 'Creator (Producers)', 'Distributors',
		'Credits', 'Language', 'Accompanying Documentation', 'Item Notes', 'Unit', 'Medium', 'Collection'
	]
	# hash mapping a column header string to a physical object' assignment operand using send()
	HEADERS_TO_ASSIGNER = {
		"#{COLUMN_HEADERS[0]}" => :location=,	"#{COLUMN_HEADERS[1]}" => :media_type=,	"#{COLUMN_HEADERS[2]}" => :iu_barcode=,
		"#{COLUMN_HEADERS[3]}" => :title=,	"#{COLUMN_HEADERS[4]}" => :copy_right=,	"#{COLUMN_HEADERS[5]}" => :series_name=,
		"#{COLUMN_HEADERS[6]}" => :series_production_number=,	"#{COLUMN_HEADERS[7]}" => :series_part=,	"#{COLUMN_HEADERS[8]}" => :alternative_title=,
		# "#{COLUMN_HEADERS[9]}" => not yet implemented
		"#{COLUMN_HEADERS[10]}" => :summary=,	"#{COLUMN_HEADERS[11]}" => :creator=,	"#{COLUMN_HEADERS[12]}" => :distributors=,
		"#{COLUMN_HEADERS[13]}" => :credits=,	"#{COLUMN_HEADERS[14]}" => :language=,	"#{COLUMN_HEADERS[15]}" => :accompanying_documentation=,
		"#{COLUMN_HEADERS[16]}" => :notes=,
		# skip the index for UNIT
		"#{COLUMN_HEADERS[18]}" => :medium=
	}


	# special logger for parsing spreadsheets
	def self.logger
		@@logger ||= Logger.new("#{Rails.root}/log/spreadsheet_submission_logger.log")
	end
	@@mutex = Mutex.new

	# this method wraps parse_spreadsheet within it's own thread of execution - see the other method for docs
	def self.parse_threaded(upload, ss, sss)
		Thread.new {
			@@mutex.synchronize do
				parse_spreadsheet(upload, ss, sss)
			end
		}
	end

	# This method takes a reference to the uploaded spreadsheet file 'file', the spreadsheet active record instance 'ss',
	# and the spread sheet submission active record instance 'sss', and processes the physical objects in the spreadsheet.
	# It either creates new records in filmdb, or logs errors as they occur line by line in the spreadsheet.
	def self.parse_spreadsheet(file, ss, sss)
		xlsx = Roo::Excelx.new(file.tempfile.path, file_warning: :ignore)
		xlsx.default_sheet = xlsx.sheets[0]
		headers = Hash.new
		xlsx.row(1).each_with_index { |header, i|
			headers[header] = i
		}

		# this array contains an entry for each row in the spreadsheet not counting the header row. A given index will
		# contain either a physical object, or the error message stating why the row entry is invalid. The index+1
		# of the array corresponds to the row within the spreadsheet.
		validated_physical_objects = Array.new

		# first check to see if the headers are well formed
		bad_header = header_problems(headers)
		if bad_header
			sss.update_attributes(failure_message: bad_header, successful_submission: false, submission_progress: 100)
		else
			# next iterate through each physical object checking it's validity - what gets appended to the array
			# is either a valid physical object or and error message stating why the object failed
			((xlsx.first_row + 1)..(xlsx.last_row)).each do |row|
				puts "Processing row #{row}"
				po = validate_physical_object(xlsx.row(row), headers)
				validated_physical_objects << po
				sss.update_attributes(submission_progress: ((row / xlsx.last_row).to_f * 50).to_i)
			end
			# get bad rows
			error_rows = validated_physical_objects.each_with_index.inject({}) { |h, (v, i)|
				h[i] = v if !v.is_a? PhysicalObject
				h
			}
			# failed import so log the failures
			if error_rows.size > 0
				msg = ""
				error_rows.keys.sort.each do |k|
					error_rows[k].messages.keys.each do |m|
						msg << "Row #{k+2}: #{m} '#{error_rows[k].messages[m]}'"
					end
					msg << "<br>"
				end
				sss.update_attributes(failure_message: msg, successful_submission: false, submission_progress: 100)
			# ingest can move forward
			else
				validated_physical_objects.each_with_index do |p, i|
					p.spreadsheet_id = ss.id
					p.save
					# subtract 1 from the 50 percent accumulated from validating objects so that the submission is not
					# complete until after sss is updated after this block
					sss.update_attributes(submission_progress: ((i / validated_physical_objects.size).to_f * 50).to_i + 49)
				end
				sss.update_attributes(successful_submission: true, submission_progress: 100)
				ss.update_attributes(successful_upload: true)
			end
		end
	end

	# this function checks the row passed to make sure it is a valid header row. It returns either nil if
	# the header is correct, or a string value containing the error message detailing what was wrong with the
	# headers
	# FIXME: Header validity has not been defined yet and may rely on collection...
	def self.header_problems(headers)
		msg = ''
		COLUMN_HEADERS.each do |ch|
			msg << bad_header_msg(ch) if headers[ch].nil?
		end
		msg.length > 0 ? msg : nil
	end

	# this function attempts to create a valid physical object from a row in a spreadsheet. If successfully
	# created, the physical object is returned, otherwise the error message (string) is returned
	def self.validate_physical_object(row_data, headers)
		po = PhysicalObject.new
		HEADERS_TO_ASSIGNER.keys.each do |k|
			puts "Assigning \"#{k}\" with #{HEADERS_TO_ASSIGNER[k]}. Value: #{row_data[headers[k]]}"
			po.send HEADERS_TO_ASSIGNER[k], row_data[headers[k]]
		end
		# manually check user who inventoried, unit, collection, and series

		# unit MUST be defined already otherwise it is a parse error and the spreadsheet should fail
		unit = Unit.where(name: row_data[headers['Unit']]).first
		if unit.nil?
			po.errors.add(:unit, "Undefined unit: #{row_data[headers['Unit']]}")
		else
			po.unit = unit
		end

		#TODO: parse user information

		# collection MUST exist already (or be blank) otherwise it is a parse error and the spreadsheet should fail
		collection = Collection.where(name: row_data[headers['Collection']]).first
		if !row_data[headers['Collection']].blank? && collection.nil?
			po.errors.add(:collection, "Unkown collection: #{row_data[headers['Collection']]}")
		elsif ! collection.nil?
			po.collection = collection
		end
		po.valid? ? po : po.errors
	end

	def self.parse_date(date)
		date.blank? ? nil : Date.strptime(date, "%Y-%m-%d")
	end

	# formats a string message based on the field specified
	def self.bad_header_msg(field)
		"Missing or malformed '#{field}' column header<br>"
	end

end
