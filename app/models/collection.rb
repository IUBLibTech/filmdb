class Collection < ActiveRecord::Base
	has_many :physical_objects, autosave: true
	belongs_to :unit, autosave: true

end
