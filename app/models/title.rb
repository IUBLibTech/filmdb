class Title < ActiveRecord::Base
	has_many :physical_objects
	belongs_to :series
	belongs_to :spreadsheet

	def series_title_text
		self.series.title if self.series
	end
end
