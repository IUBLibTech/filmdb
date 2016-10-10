class Collection < ActiveRecord::Base
	has_many :physical_objects
	belongs_to :unit
	has_one :collection_inventory_configuration

	MISC_COLLECTION_NAME = "Misc [not in collection]"
end
