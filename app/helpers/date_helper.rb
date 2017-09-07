module DateHelper

	@@year_rgx = /([0-9]{4})/
	@@year_month_rgx = /([0-9]{4})\/([0-9]{1,2})/
	@@year_month_day_rgx = /([0-9]{4})\/([0-9]{1,2})\/([0-9]{1,2})/

	# Tests if the specified string is a 4 digit value - does not test if the year is 'meaningful': '0000' would return the MatchData
	def year_only?(date)
		date.length == 4 && @@year_rgx.match(date)
	end

	def year_month?(date)
		@@year_month_rgx.match(date)
	end

	def year_month_day?(date)
		@@year_month_day_rgx.match(date)
	end

	# returns nil if there was no pattern matching against the specified string, or a map of the following:
	# :date contains a valid Date object
	# :month is a boolean value specifying whether the month was present in the date string
	# :day a boolean value specifying whether the day was present in the date string
	# :extra is a boolean value specifying whether there was additional text beyond the pattern matched
	def convert_to_date(date)
		match = year_month_day?(date)
		if match.nil?
			match = year_month?(date)
			if match.nil?
				match = year_only?(date)
			end
		end
		if match.nil?
			nil
		else
			year = match[1].to_i
			puts year
			month = match[2]&.to_i
			day = match[3]&.to_i
			d = day.nil? ? (month.nil? ? Date.new(year) : Date.new(year, month)) : Date.new(year, month, day)
			map = {}
			map[:date] = d
			map[:month] = !match[2].nil?
			map[:day] = !match[3].nil?
			map[:extra] = (match[0].length != date.length)
			map
		end
	end


end
