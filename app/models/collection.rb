class Collection < ActiveRecord::Base
	has_many :physical_objects, autosave: true
	belongs_to :unit, autosave: true
	has_one :collection_inventory_configuration, autosave: true

	MISC_COLLECTION_NAME = "Misc [not in collection]"
end
