class PhysicalObjectsController < ApplicationController
  before_action :set_physical_object, only: [:show, :edit, :update, :destroy]

  # GET /physical_objects
  # GET /physical_objects.json
  def index
    @physical_objects = PhysicalObject.all
  end

  # GET /physical_objects/1
  # GET /physical_objects/1.json
  def show
  end

  # GET /physical_objects/new
  def new
    @physical_object = PhysicalObject.new
  end

  # GET /physical_objects/1/edit
  def edit
    @physical_object = PhysicalObject.find(params[:id])
    if @physical_object.nil?
      flash.now[:warning] = "No such physical object..."
      redirect_to :back
    end
  end

  # POST /physical_objects
  # POST /physical_objects.json
  def create
    @physical_object = PhysicalObject.new(physical_object_params)

    respond_to do |format|
      if @physical_object.save
        format.html { redirect_to @physical_object, notice: 'Physical object was successfully created.' }
        format.json { render :show, status: :created, location: @physical_object }
      else
        format.html { render :new }
        format.json { render json: @physical_object.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /physical_objects/1
  # PATCH/PUT /physical_objects/1.json
  def update
    respond_to do |format|
      if @physical_object.update(physical_object_params)
        format.html { redirect_to @physical_object, notice: 'Physical object was successfully updated.' }
        format.json { render :show, status: :ok, location: @physical_object }
      else
        format.html { render :edit }
        format.json { render json: @physical_object.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /physical_objects/1
  # DELETE /physical_objects/1.json
  def destroy
    @physical_object.destroy
    respond_to do |format|
      format.html { redirect_to physical_objects_url, notice: 'Physical object was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_physical_object
      @physical_object = PhysicalObject.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def physical_object_params
      params.require(:physical_object).permit(
        :date_inventoried, :location, :media_type, :medium, :iu_barcode, :title_id, :copy_right, :format, :spreadsheet_id,
        :series_name, :series_production_number, :series_part, :alternative_title, :title_version, :item_original_identifier,
        :summary, :creator, :distributors, :credits, :language, :accompanying_documentation, :notes, :unit_id
      )
    end
end
