class Title < ActiveRecord::Base
	has_many :physical_objects
	belongs_to :series
	belongs_to :spreadsheet
end
