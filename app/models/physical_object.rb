class PhysicalObject < ActiveRecord::Base
	has_many :physical_object_old_barcodes
	belongs_to :spreadhsheet

	trigger.after(:update).of(:iu_barcode) do
		"INSERT INTO physical_object_old_barcodes(physical_object_id, iu_barcode) VALUES(OLD.id, OLD.iu_barcode)"
	end

	def media_types
		['Moving Image', 'Audio']
	end

end
