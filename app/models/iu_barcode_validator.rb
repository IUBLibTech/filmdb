class IuBarcodeValidator < ActiveModel::EachValidator

	def validate_each(record, attribute, value)
		assigned = ApplicationHelper.iu_barcode_assigned?(value)
		if !ApplicationHelper.valid_barcode?(value)
			record.errors.add(attribute, options[:message] || "is not valid.")
		elsif (assigned and assigned != record)
			record.errors.add(attribute, options[:message] || error_message_link(assigned))
		end
	end

	private
		def error_message_link(assigned)
			"#{assigned.iu_barcode} has already been assigned to a #{assigned.class.to_s.titleize}"
		end
end
