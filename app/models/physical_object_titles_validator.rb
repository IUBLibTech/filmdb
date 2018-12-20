class PhysicalObjectTitlesValidator < ActiveModel::EachValidator

	def validate_each(record, attribute, value)
		if value.size == 0
			record.errors.add(attribute, options[:message] || "must have at least one title assigned")
		end
	end

end