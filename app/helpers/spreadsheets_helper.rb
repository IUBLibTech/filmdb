module SpreadsheetsHelper
	require 'roo'

	# special logger for parsing spreadsheets
	def self.logger
		@@logger ||= Logger.new("#{Rails.root}/log/spreadsheet_submission_logger.log")
	end
	@@mutex = Mutex.new

	def self.parse_invoice(upload)
		Thread.new {
			@@mutex.synchronize do
				parse_spreadsheet(upload)
			end
		}
	end


	def self.parse_spreadsheet(file)
		ss = Spreadsheet.where(filename: file.original_filename).first
		raise "A spreadsheet with filename #{file.original_filename} has already been successfully uploaded" unless (ss.nil? || (ss.successful_upload == false))
		# either a new file submission
		if ss.nil?
			ss = Spreadsheet.new(filename: file.original_filename);
			ss.save
		end
		sss = SpreadsheetSubmission.new(spreadsheet_id: ss.id)
		sss.save

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
		bad_header = head_problems(xlsx.row(0))
		if bad_header
			sss.update_attributes(failure_message: bad_header, successful_submission: false, submission_progress: 100)
		else
			# next iterate through each physical object checking it's validity - what gets appended to the array
			# is either a valid physical object or and error message stating why the object failed
			((xlsx.first_row + 1)..(xlsx.last_row)).each do |row|
				validated_physical_objects << validate_physical_object(xlsx.row(row), headers)
				sss.update_attributes(submission_progress: ((row / xlsx.last_row).to_f * 50).to_i)
			end
			# get bad rows
			error_rows = validated_physical_objects.each_with_index.inject({}) { |h, (v, i)|
				h[i] = v if v.is_a? String
				h
			}
			# failed import so log the failures
			if error_rows.size > 0
				msg = ""
				error_rows.keys.sort.each do |k|
					msg << "Row #{k}: #{error_rows[k]}\n"
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
	def self.head_problems(row_data)
		nil
	end

	# this function attempts to create a valid physical object from a row in a spreadsheet. If successfully
	# created, the physical object is returned, otherwise the error message (string) is returned
	def self.validate_physical_object(row_data, headers)
		po = PhysicalObject.new(
				date_inventoried: parse_date(row_data[headers['Date Inventoried*']]),
				# FIXME: how to handle spreadsheets that list a user that is not in the filmdb users table???
				location: row_data[headers['Location*']],
				media_type: row_data[headers['Media Type*']],
				iu_barcode: row_data[headers['Item Barcode*']],
				title: row_data[headers['Title*']],
				copy_right: row_data[headers['Copyright']],
				# FIXME: format needs to be fleshed out...
				# format: row_data[headers['Medium*']],
				# spreadsheet_id: ss.id - this needs to be set when the physical object is saved
				series_name: row_data[headers['Series Name']],
				series_production_number: row_data[headers['Series Production Number']],
				series_part: row_data[headers['Series Part']],
				alternative_title: row_data[headers['Alternative Title']],
				title_version: row_data[headers['Item Original Identifier']],
				summary: row_data[headers['Summary']],
				creator: row_data[headers['Creator (Producers)']],
				distributors: row_data[headers['Distributors']],
				credits: row_data[headers['Credits']],
				language: row_data[headers['Language']],
				accompanying_documentation: row_data[headers['Accompanying Documentation']],
				notes:  row_data[headers['Accompanying Documentation']]
		)
	end

	def self.parse_date(date)
		date.blank? ? nil : Date.strptime(date, "%Y-%m-%d")
	end

end
