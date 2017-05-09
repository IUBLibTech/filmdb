xml.instruct! :xml, :version=>"1.0"

xml.batches do
	xml.batch do
		# need to figure out out to generate an identifier for a cage
		xml.identifier @cage.top_shelf.identifier
		xml.description @cage.top_shelf.notes
		xml.bin do
			xml.identifier @cage.top_shelf.identifier
			xml.mdpiBarcode @cage.top_shelf.mdpi_barcode
			xml.description @cage.top_shelf.notes
			xml.destination 'Memnon'
			xml.format @cage.top_shelf.physical_objects.first.medium
			xml.objectsCount @cage.top_shelf.physical_objects.size
			xml.physicalObjecst do
				@cage.top_shelf.physical_objects do |p|
					xml.physicalObject do
						xml.filmdbId p.id
						xml.mdpiBarcode p.mdpi_barcode
						xml.iucatBarcode p.iu_barcode
						xml.format p.medium
						xml.unit p.unit.abbreviation
						xml.title p.titles.collect { |t| t.title_text }.join(", ")
						xml.collectionName p.collection.name

					end
				end
			end
		end
	end

end


