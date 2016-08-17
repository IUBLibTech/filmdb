class Spreadsheet < ActiveRecord::Base
	has_many :physical_objects
	has_many :spreadsheet_submissions

	def current_submission
		spreadsheet_submissions.order(:created_at).last
	end

end
