class SearchController < ApplicationController

	def barcode_search
		@physical_object = PhysicalObject.where("iu_barcode = ? OR mdpi_barcode = ?", params[:barcode], params[:barcode]).first
		if @physical_object
			render 'physical_objects/show'
		else
			@obj = CageShelf.where(mdpi_barcode: params[:barcode]).first
			if @obj
				@cage = @obj.cage
				render 'cages/cage'
			else
				render 'search/search_results'
			end
		end
	end

end