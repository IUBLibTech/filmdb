class Unit < ActiveRecord::Base
	has_many :physical_objects
	has_many :collections

	def misc_collection
		Collection.where(unit: self, name: 'Misc [not in collection]').first
	end
end
