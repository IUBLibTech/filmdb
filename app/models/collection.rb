class Collection < ActiveRecord::Base
	has_many :physical_objects
	belongs_to :unit

	MISC_COLLECTION_NAME = "Misc [not in collection]"
end
