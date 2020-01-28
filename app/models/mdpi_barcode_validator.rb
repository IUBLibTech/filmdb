class MdpiBarcodeValidator < ActiveModel::EachValidator

	def validate_each(record, attribute, value)
		unless value.blank?
			assigned = ApplicationHelper.mdpi_barcode_assigned?(value)
			debugger
			if !ApplicationHelper.valid_barcode?(value, true)
				record.errors.add(attribute, options[:message] || "is not valid.")
			elsif assigned && (assigned.is_a?(CageShelf) && assigned != record)
				record.errors.add(attribute, option[:message] || error_message_link(assigned))
			elsif assigned && assigned.is_a?(PhysicalObject) && record != assigned.acting_as
				record.errors.add(attribute, options[:message] || error_message_link(assigned))
			end
		end
	end

	private
		def error_message_link(assigned)
			"#{assigned.mdpi_barcode} has already been assigned to a #{assigned.class.to_s.titleize}"
		end
end
