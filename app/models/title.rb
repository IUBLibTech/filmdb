class Title < ActiveRecord::Base
	has_many :physical_objects
	belongs_to :series_title
end
