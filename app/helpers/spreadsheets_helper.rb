module SpreadsheetsHelper
	require 'roo'
	def self.parse_spreadsheet(file)
		ss = Spreadsheet.where(filename: file.original_filename).first
		raise "A spreadsheet with filename #{file.original_filename} has already been uploaded" unless ss.nil?

		ss = Spreadsheet.new(filename: file.original_filename)
		ss.save
		xlsx = Roo::Excelx.new(file.tempfile.path, file_warning: :ignore)
		xlsx.default_sheet = xlsx.sheets[0]
		headers = Hash.new
		xlsx.row(1).each_with_index { |header, i|
			headers[header] = i
		}
		((xlsx.first_row + 1)..(xlsx.last_row)).each do |row|
			puts "Should be creating physical object: #{row}"
			po = PhysicalObject.new(
				date_inventoried: parse_date(xlsx.row(row)[headers['Date Inventoried*']]),
				# FIXME: how to handle spreadsheets that list a user that is not in the filmdb users table???
				location: xlsx.row(row)[headers['Location*']],
				media_type: xlsx.row(row)[headers['Media Type*']],
				iu_barcode: xlsx.row(row)[headers['Item Barcode*']],
				title: xlsx.row(row)[headers['Title*']],
				copy_right: xlsx.row(row)[headers['Copyright']],
				# FIXME: format needs to be fleshed out...
				# format: xlsx.row(row)[headers['Medium*']],
				spreadsheet_id: ss.id,
				series_name: xlsx.row(row)[headers['Series Name']],
				series_production_number: xlsx.row(row)[headers['Series Production Number']],
				series_part: xlsx.row(row)[headers['Series Part']],
				alternative_title: xlsx.row(row)[headers['Alternative Title']],
				title_version: xlsx.row(row)[headers['Item Original Identifier']],
				summary: xlsx.row(row)[headers['Summary']],
				creator: xlsx.row(row)[headers['Creator (Producers)']],
				distributors: xlsx.row(row)[headers['Distributors']],
				credits: xlsx.row(row)[headers['Credits']],
				language: xlsx.row(row)[headers['Language']],
				accompanying_documentation: xlsx.row(row)[headers['Accompanying Documentation']],
				notes:  xlsx.row(row)[headers['Accompanying Documentation']]
			)
			po.save
		end
	end

	def self.parse_date(date)
		date.blank? ? nil : Date.strptime(date, "%Y-%m-%d")
	end

end
