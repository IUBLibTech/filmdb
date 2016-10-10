class Spreadsheet < ActiveRecord::Base
	has_many :physical_objects
	has_many :spreadsheet_submissions
	has_many :created_users, class_name: "User", foreign_key: "created_in_spreadsheet"

	def current_submission
		spreadsheet_submissions.order(:created_at).last
	end

end
