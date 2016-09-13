class PhysicalObject < ActiveRecord::Base
	include ActiveModel::Validations

	belongs_to :title
	has_many :physical_object_old_barcodes
	belongs_to :spreadhsheet
	belongs_to :collection
	belongs_to :unit

	validates :title_id, presence: true
	validates :iu_barcode, iu_barcode: true
	validates :unit, presence: true
	validates :media_type, presence: true
	validates :medium, presence: true

	trigger.after(:update).of(:iu_barcode) do
		"INSERT INTO physical_object_old_barcodes(physical_object_id, iu_barcode) VALUES(OLD.id, OLD.iu_barcode)"
	end

	MEDIA_TYPES = ['Moving Image', 'Recorded Sound', 'Still Image', 'Text', 'Three Dimensional Object', 'Software', 'Mixed Material']
	MEDIA_TYPE_MEDIUMS = {
		'Moving Image' => ['Film', 'Video', 'Digital'],
		'Recorded Sound' => ['Recorded Sound'],
		'Still Image' => ['Still Image'],
		'Text' => ['Text'],
		'Three Dimensional Object' => ['Three Dimensional Object'],
		'Software' => ['Software'],
		'Mixed Media' => ['Mixed Media']
	}

	def media_types
		MEDIA_TYPES
	end

	def media_type_mediums
		MEDAI_TYPE_MEDIUMS
	end

end
