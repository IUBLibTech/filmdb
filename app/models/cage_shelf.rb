class CageShelf < ActiveRecord::Base

  belongs_to :cage
  has_many :physical_objects

	SEC = 1
	MIN = 60
	HR = 60 * MIN

	SECONDS_PER_FOOT = {
		:gauge => 2
	}

	# used in the ajax form submission of adding a physical object to a cage shelf
	attr_accessor :physical_object_mdpi_barcode

  def initialize(*args)
    super
    self.identifier ||= ''
    self.notes ||= ''
  end

	def duration
		physical_objects.nil? ? 0 : calc_duration_from_footage(physical_objects.sum(:footage))
	end

	private
	def calc_duration_from_footage(ft)
		format_time_code(ft * SECONDS_PER_FOOT[:gauge])
	end

	def format_time_code(sec)
		if sec > 0
			Time.at(sec).utc.strftime("%H:%M:%S")
		else
			"00:00:00"
		end
	end
end
