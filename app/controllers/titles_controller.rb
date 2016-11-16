class TitlesController < ApplicationController
  include PhysicalObjectsHelper
  before_action :set_title, only: [:show, :edit, :update, :destroy, :create_physical_object, :new_physical_object]

  # GET /titles
  # GET /titles.json
  def index
    @titles = Title.all
  end

  # GET /titles/1
  # GET /titles/1.json
  def show
    @physical_objects = @title.physical_objects
  end

  # GET /titles/new_physical_object
  def new
    @title = Title.new
  end

  # GET /titles/1/edit
  def edit
  end

  # POST /titles
  # POST /titles.json
  def create
    @title = Title.new(title_params)
    respond_to do |format|
      if @title.save
        format.html { redirect_to @title, notice: 'Title was successfully created.' }
        format.json { render :show, status: :created, location: @title }
      else
        format.html { render :new_physical_object }
        format.json { render json: @title.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /titles/1
  # PATCH/PUT /titles/1.json
  def update
    respond_to do |format|
      if @title.update(title_params)
        format.html { redirect_to @title, notice: 'Title was successfully updated.' }
        format.json { render :show, status: :ok, location: @title }
      else
        format.html { render :edit }
        format.json { render json: @title.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /titles/1
  # DELETE /titles/1.json
  def destroy
    @title.destroy
    respond_to do |format|
      format.html { redirect_to titles_url, notice: 'Title was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def new_physical_object
    @physical_object = PhysicalObject.new(title_id: @title.id)
  end

  def autocomplete_title
    if params[:term]
      json = Title.joins("LEFT JOIN `series` ON `series`.`id` = `titles`.`series_id`").where("title_text like ?", "%#{params[:term]}%").select('titles.id, title_text, titles.description, series_id, series.title').to_json
      json.gsub! "\"title_text\":", "\"label\":"
      json.gsub! "\"id\":", "\"value\":"
      json.gsub! "\"title\":", "\"series_title\":"
      render json: json
    else
      render json: ''
    end
  end

  def autocomplete_title_for_series
    if params[:series_id] && params[:term]
      json = Title.where("series_id = ? and title_text like ?", params[:series_id], "%#{params[:term]}%").select(:id, :title_text, :description).to_json
      json.gsub! "\"title_text\":", "\"label\":"
      json.gsub! "\"id\":", "\"value\":"
      render json: json
    else
      render json: ''
    end
  end

  def autocomplete_title_for_collection

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_title
      @title = Title.find(params[:id])
      @cv = ControlledVocabulary.physical_object_cv
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def title_params
      params.require(:title).permit(:title_text, :description, :series_id, :series_title_index)
    end
end