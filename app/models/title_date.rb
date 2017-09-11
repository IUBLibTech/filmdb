class TitleDate < ActiveRecord::Base
	include DateHelper
  after_validation :normalize_date_fields



  def ==(another)
    self.class == another.class && self.start_date == another.start_date && self.date_type == another.date_type  && self.month_present == another.month_present && self.day_present == another.day_present
  end

	def date_to_s
		if day_present?
			start_date.strftime("%Y/%m/%d")
		elsif month_present?
			start_date.strftime("%Y/%m")
		else
			start_date.strftime("%Y")
		end
	end

  def normalize_date_fields
    map = convert_to_date(date_text)
	  if map
		  self.start_date = map[:date]
		  self.month_present=map[:month]
		  self.day_present=map[:day]
		  self.extra_text=map[:extra]
	  end
  end
end
