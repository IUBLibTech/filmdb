class TitleDate < ActiveRecord::Base
	include DateHelper

	# the constructor is responsible for parsing date_text to turn it into coresponding start and end dates based on the string passed
	def initialize(attributes = {})
		super(attributes)
		unless attributes[:date_text].blank?
			parse_date_text
		end
	end

  def ==(another)
    self.class == another.class && self.date_type == another.date_type && self.date_to_s == another.date_to_s
  end


end
