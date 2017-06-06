module CagesHelper
	require "builder"

	# creates an xml file containing the "batch" contents of the specified cage and returns the path to the temp file created
	def write_xml(cage)
		xml = Builder::XmlMarkup.new(indent: 2)
		cage_as_batches_xml(cage, xml)
		xml_data = xml.target!
		file = File.new("tmp/cage_#{@cage.identifier}.xml", "wb")
		file.write(xml_data)
		file.close()
		file.path
	end

	def cage_as_batches_xml(cage, builder)
		builder.instruct! :xml, :version=>"1.0"
		builder.batches do
			builder.batch do
				# need to figure out out to generate an identifier for a cage
				builder.identifier cage.top_shelf.identifier
				builder.description cage.top_shelf.notes
				builder.bin do
					builder.identifier cage.top_shelf.identifier
					builder.mdpiBarcode cage.top_shelf.mdpi_barcode
					builder.description cage.top_shelf.notes
					builder.destination 'Memnon'
					builder.format cage.top_shelf.physical_objects.first&.medium
					builder.objectsCount cage.top_shelf.physical_objects.size
					builder.physicalObjecst do
						cage.top_shelf.physical_objects.each do |p|
							p.to_xml(builder: builder)
						end
					end
				end
				builder.bin do
					builder.identifier cage.middle_shelf.identifier
					builder.mdpiBarcode cage.middle_shelf.mdpi_barcode
					builder.description cage.middle_shelf.notes
					builder.destination 'Memnon'
					builder.format cage.middle_shelf.physical_objects.first&.medium
					builder.objectsCount cage.middle_shelf.physical_objects.size
					builder.physicalObjecst do
						cage.middle_shelf.physical_objects.each do |p|
							p.to_xml(builder: builder)
						end
					end
				end
				builder.bin do
					builder.identifier cage.bottom_shelf.identifier
					builder.mdpiBarcode cage.bottom_shelf.mdpi_barcode
					builder.description cage.bottom_shelf.notes
					builder.destination 'Memnon'
					builder.format cage.bottom_shelf.physical_objects.first&.medium
					builder.objectsCount cage.bottom_shelf.physical_objects.size
					builder.physicalObjecst do
						cage.bottom_shelf.physical_objects.each do |p|
							p.to_xml(builder: builder)
						end
					end
				end
			end
		end
		builder
	end
	
end
