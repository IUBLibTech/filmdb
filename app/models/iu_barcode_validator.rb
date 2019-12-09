class IuBarcodeValidator < ActiveModel::EachValidator

	def validate_each(record, attribute, value)
		assigned = ApplicationHelper.iu_barcode_assigned?(value)
		if !ApplicationHelper.valid_barcode?(value)
			record.errors.add(attribute, options[:message] || "is not valid.")
		elsif assigned && assigned != record.acting_as
			# it's important that the above test checks against PhysicalObject vs PhysicalObject. The 'record' is passed in
			# as it's subtype (Film/Video) and assigned returns the base PhysicalObject since we don't want any PO with that
			# BARCODE
			record.errors.add(attribute, options[:message] || error_message_link(assigned))
		end
	end

	private
		def error_message_link(assigned)
			"#{assigned.iu_barcode} has already been assigned to a #{assigned.class.to_s.titleize}"
		end
end
