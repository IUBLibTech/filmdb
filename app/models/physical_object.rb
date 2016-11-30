class PhysicalObject < ActiveRecord::Base
	include ActiveModel::Validations

	belongs_to :title
	has_many :physical_object_old_barcodes
	belongs_to :spreadhsheet
	belongs_to :collection
	belongs_to :unit
	belongs_to :inventorier, class_name: "User", foreign_key: "inventoried_by"
	belongs_to :modifier, class_name: "User", foreign_key: "modified_by"

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

	# title_text, series_title_text, and collection_text are all necesasary for javascript autocomplete on these fields for
	# forms. They provide a display value for the title/series/collection but are never set directly - the id of the model record
	# is set and passed as the param for assignment
	def title_text
		self.title.title_text if self.title
	end

	def series_title_text
		self.title.series.title if self.title && self.title.series
	end

	def series_id
		self.title.series.id if self.title && self.title.series
	end

	def collection_text
		self.collection.name if self.collection
	end

	# duration is input as hh:mm:ss
	def duration=(time)
		super(time.split(':').map { |a| a.to_i }.inject(0) { |a, b| a * 60 + b})
  end

  # duration is viewed as hh:mm:ss
  def duration
    unless super.nil?
      hh = (super / 3600).floor
      mm = ((super - (hh * 3600)) / 60).floor
      ss = super - (hh * 3600) - (mm * 60)
      "#{hh}:#{mm}:#{ss}"
    end
  end

end
