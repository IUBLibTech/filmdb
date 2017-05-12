class CagesController < ApplicationController
	include CagesHelper
	include ServicesHelper

  before_action :set_cage, only: [:show, :edit, :update, :destroy, :show_xml]

	before_action :set_cage_shelf, only: [:shelf_physical_objects, :add_physical_object_to_shelf, :remove_physical_object]
	before_action :set_physical_object, only: [:add_physical_object_to_shelf]

  # GET /cages
  # GET /cages.json
  def index
    @cages = Cage.all
  end

  # GET /cages/1
  # GET /cages/1.json
  def show
		respond_to do |format|
			format.html
		end
  end

  # GET /cages/new
  def new
    @cage = Cage.new
  end

  # GET /cages/1/edit
  def edit
  end

  # POST /cages
  # POST /cages.json
  def create
    @cage = Cage.new(cage_params)
    respond_to do |format|
      if @cage.save
        format.html { redirect_to @cage, notice: 'Cage was successfully created.' }
        format.json { render :show, status: :created, location: @cage }
      else
        format.html { render :new }
        format.json { render json: @cage.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cages/1
  # PATCH/PUT /cages/1.json
  def update
    respond_to do |format|
      if @cage.update(cage_params)
        format.html { redirect_to @cage, notice: 'Cage was successfully updated.' }
        format.json { render :show, status: :ok, location: @cage }
      else
        format.html { render :edit }
        format.json { render json: @cage.errors, status: :unprocessable_entity }
      end
    end
  end

	def shelf_physical_objects
		render partial: 'cage_shelf_physical_objects'
	end

  def add_physical_object_to_shelf
    if @physical_object.nil? || (!@physical_object.cage_shelf.nil? && @physical_object.cage_shelf != @cage_shelf)
			@msg = @physical_object.nil? ? "Could not find Physical Object with barcode #{params[:barcode]}" : "Physical Object #{@physical_object.mdpi_barcode} already belongs to Shelf #{link_to @physical_object.cage_shelf.identifier cage_path(@physical_object.cage_shelf.cage) }"
      render partial: 'ajax_add_po_failure'
    else
      @physical_object.update_attributes(cage_shelf_id: @cage_shelf.id)
			@msg = "Physical Object #{@physical_object.mdpi_barcode} was successfully added to Shelf #{@physical_object.cage_shelf.identifier}"
      render partial: 'ajax_add_po_success'
		end
	end

	def remove_physical_object
		# don't add this call to before_action :set_physical_object - the PO is determined by different passed params (mdpi_barcode vs po.id)
		@physical_object = PhysicalObject.find(params[:po_id])
		if @physical_object.nil? || (@physical_object.cage_shelf != @cage_shelf)
			@msg = "Physical Object #{params[:barcode]} either doesn't exist, or is not contained in this Shelf"
			render partial: 'ajax_add_po_failure'
		else
			@msg = "Physical Object #{@physical_object.mdpi_barcode} successfully removed from Shelf #{@cage_shelf.identifier}"
			@physical_object.update_attributes(cage_shelf: nil)
			@cage_shelf.reload
			render partial: 'ajax_add_po_success'
		end
	end

  # DELETE /cages/1
  # DELETE /cages/1.json
  def destroy
    @cage.destroy
    respond_to do |format|
      format.html { redirect_to cages_url, notice: 'Cage was successfully destroyed.' }
      format.json { head :no_content }
    end
	end

	def show_xml
		# file_path = write_xml(@cage)
		# render file: file_path, layout: false, status: 200
		debugger
		something = push_cage_to_pod(@cage.id)
		render text: something.to_yaml, status: 200
	end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cage
      @cage = Cage.find(params[:id])
		end

		def set_cage_shelf
			@cage_shelf = CageShelf.find(params[:id])
		end

		def set_physical_object
			@physical_object = PhysicalObject.where(iu_barcode: params[:barcode]).first
		end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cage_params
      params.require(:cage).permit(:identifier, :notes,
         #top_shelf: [:id, :identifier, :mdpi_barcode, :notes, :_destroy],
         #middle_shelf: [:id, :identifier, :mdpi_barcode, :notes, :_destroy],
         #bottom_shelf: [:id, :identifier, :mdpi_barcode, :notes,:_destroy],
         top_shelf_attributes: [:id, :identifier, :mdpi_barcode, :notes, :_destroy],
         middle_shelf_attributes: [:id, :identifier, :mdpi_barcode, :notes, :_destroy],
         bottom_shelf_attributes: [:id, :identifier, :mdpi_barcode, :notes, :_destroy]
      )
    end
end
