class Unit < ActiveRecord::Base
	has_many :physical_objects, autosave: true
	has_many :collections, autosave: true

	def misc_collection

	end
end
