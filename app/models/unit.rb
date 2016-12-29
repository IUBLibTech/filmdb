class Unit < ActiveRecord::Base
	has_many :physical_objects, autosave: true
	has_many :collections, autosave: true

	def misc_collection
		Collection.where(unit: self, name: 'Misc [not in collection]').first
	end
end
