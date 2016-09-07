class Collection < ActiveRecord::Base
	has_many :physical_objects
	belongs_to :unit
end
