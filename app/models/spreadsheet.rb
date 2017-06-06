class Spreadsheet < ActiveRecord::Base
	has_many :physical_objects
	has_many :spreadsheet_submissions, dependent: :delete_all
  has_many :titles
  has_many :series
	has_many :created_users, class_name: "User", foreign_key: "created_in_spreadsheet"

  scope :distinct_series, -> (spreadsheet_id) {
    Series.select(:title).where(spreadsheet_id: spreadsheet_id).distinct.order(:title).pluck(:title)
  }

  scope :distinct_titles, -> (spreadsheet_id) {
    Title.select(:title_text).where(spreadsheet_id: spreadsheet_id).distinct.order(:title_text).pluck(:title_text)
  }

	def current_submission
		spreadsheet_submissions.order(:created_at).last
	end

end
