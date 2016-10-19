class CollectionsController < ApplicationController
  before_action :set_collection, only: [:show, :edit, :update, :destroy, :new_physical_object, :create_physical_object]
  before_action :init_create_physical_object, only: [:new_physical_object, :create_physical_object]

  # GET /collections
  # GET /collections.json
  def index
    @collections = Collection.all
  end

  # GET /collections/1
  # GET /collections/1.json
  def show
  end

  # GET /collections/new
  def new
    @collection = Collection.new
  end

  # GET /collections/1/edit
  def edit
  end

  # POST /collections
  # POST /collections.json
  def create
    @collection = Collection.new(collection_params)

    respond_to do |format|
      if @collection.save
        format.html { redirect_to @collection, notice: 'Collection was successfully created.' }
        format.json { render :show, status: :created, location: @collection }
      else
        format.html { render :new }
        format.json { render json: @collection.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /collections/1
  # PATCH/PUT /collections/1.json
  def update
    respond_to do |format|
      if @collection.update(collection_params)
        format.html { redirect_to @collection, notice: 'Collection was successfully updated.' }
        format.json { render :show, status: :ok, location: @collection }
      else
        format.html { render :edit }
        format.json { render json: @collection.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /collections/1
  # DELETE /collections/1.json
  def destroy
    @collection.destroy
    respond_to do |format|
      format.html { redirect_to collections_url, notice: 'Collection was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def new_physical_object

  end

  def create_physical_object
    @physical_object = PhysicalObject.new(physical_object_params)
    # it is possible that a new title is created in which case params[:physical_object][:title_id] will be null,
    # but params[:physical_object][:title_text] will not be null
    if params[:physical_object][:title_id].blank? && !params[:physical_object][:title_text].blank?
      new_title = Title.new(title_text: params[:physical_object][:title_text],
                            description: "*This description was auto-generated because a new title was created at physical object creation/edit.*")
      new_title.save
      @physical_object.title = new_title
    end
    respond_to do |format|
      if @physical_object.save
        if params[:series].blank?
          @physical_object.title.series =  nil
        else
          @physical_object.title.series_id = params[:series]
        end
        @physical_object.title.save
        format.html { redirect_to  collection_new_physical_object_path , notice: 'Physical Object successfully created' }
      else
        format.html { render :new_physical_object }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_collection
      @collection = Collection.find(params[:id])
      @collection_inventory_configuration = @collection.collection_inventory_configuration
    end

    def init_create_physical_object
      @user = User.where(username: current_user).first
      @series = Series.all
      @physical_object = PhysicalObject.new(collection_id: @collection.id, unit_id: @collection.unit.id, inventoried_by: @user.id )
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def collection_params
      params.require(:collection).permit(:name, :unit_id)
    end

    def physical_object_params
      params.require(:physical_object).permit(
          :date_inventoried, :location, :media_type, :medium, :iu_barcode, :title_id, :copy_right, :format, :spreadsheet_id, :inventoried_by,
          :series_name, :series_production_number, :series_part, :alternative_title, :title_version, :item_original_identifier,
          :summary, :creator, :distributors, :credits, :language, :accompanying_documentation, :notes, :unit_id, :collection_id
      )
    end
end
