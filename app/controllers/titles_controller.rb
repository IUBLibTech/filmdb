class TitlesController < ApplicationController
  include PhysicalObjectsHelper
  before_action :set_title, only: [:show, :edit, :update, :destroy, :create_physical_object, :new_physical_object, :ajax_summary, :create_component_group]
  before_action :set_series, only: [:create, :create_ajax]
  before_action :set_physical_object_cv, only:[:create_physical_object, :new_physical_object]
  before_action :set_all_title_cv, only: [:new, :edit, :new_ajax]

  # GET /titles
  # GET /titles.json
  def index
    @titles = Title.all
  end

  # GET /titles/1
  # GET /titles/1.json
  def show
    @physical_objects = @title.physical_objects
    @component_group_cv = ControlledVocabulary.component_group_cv
  end

  # GET /titles/new_physical_object
  def new
    u = User.current_user_object
    @title = Title.new(modified_by_id: u.id, created_by_id: u.id)
  end

  # GET /titles/1/edit
  def edit
    @title.modified_by_id = User.current_user_object.id
    if @title.nil?
      flash.now[:warning] = "No such title..."
      redirect_to :back
    end
  end

  # POST /titles
  # POST /titles.json
  def create
    @title = Title.new(title_params)
    if @series
      @title.series_id = @series.id
    elsif !params[:title][:series_title_text].blank?
      @series = Series.new(title: params[:title][:series_title_text])
      @series.save
      @title.series_id = @series.id
    end
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

  def create_component_group
    @component_group_cv = ControlledVocabulary.component_group_cv
    po_ids = params[:pos][:po_ids].split(",")
    # make sure that all submitted po ids actually belong to the title
    pos = PhysicalObject.where(id: po_ids)
    bad = pos.reject { |p| p.belongs_to_title? @title.id }.collect { |p| p.iu_barcode }
    respond_to do |format|
      if bad.size > 0
        format.html { render :show, warning: "The following Physical Objects do not belong to this title: #{bad.map(&:inspect).join(", ")}"}
      else
        cg = nil
        ComponentGroup.transaction do
          cg = ComponentGroup.new(group_type: params[:pos][:group_type], title_id: @title.id, group_summary: params[:pos][:group_summary])
          cg.save
          pos.each do |p|
            ComponentGroupPhysicalObject.new(physical_object_id: p.id, component_group_id: cg.id).save
          end
        end
        format.html { redirect_to title_path(@title), notice: "Component Group <i>#{cg.group_type}</i> Created." }
      end
    end
  end

  def new_ajax
    u = User.current_user_object
    @title = Title.new(modified_by_id: u.id, created_by_id: u.id);
    @series = Series.where(id: params[:series_id]).first
    @title.series = @series
    render partial: 'form'
  end

  def create_ajax
    @title = Title.new(title_params)
    if @series
      @title.series_id = @series.id
    elsif !params[:title][:series_title_text].blank?
      @series = Series.new(title: params[:title][:series_title_text])
      @series.save
      @title.series_id = @series.id
    end
    respond_to do |format|
      if @title.save
        format.json {render json: {title_id: @title.id, title_text: @title.title_text, series_id: (@series.nil? ? 0 : @series.id), series_title: @series.nil? ? '' : @series.title}, status: :created}
      else
        format.json {
          render json: { error: 'Something bad happened while trying to save the title...', status: :unprocessable_entity }
        }
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
    authorize Title
    @title.destroy
    respond_to do |format|
      format.html { redirect_to titles_url, notice: 'Title was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def new_physical_object
    @em = 'Creating New Physical Object'
    @physical_object = PhysicalObject.new
    @physical_object.titles << @title
    render 'physical_objects/new_physical_object'
  end

  def autocomplete_title
    if params[:term]
      json = Title.joins("LEFT JOIN `series` ON `series`.`id` = `titles`.`series_id`").where("title_text like ?", "%#{params[:term]}%").select('titles.id, title_text, titles.summary, series_id, series.title').to_json
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
      json = Title.where("series_id = ? and title_text like ?", params[:series_id], "%#{params[:term]}%").select(:id, :title_text, :summary).to_json
      json.gsub! "\"title_text\":", "\"label\":"
      json.gsub! "\"id\":", "\"value\":"
      render json: json
    else
      render json: ''
    end
  end

  def ajax_summary
    #@title = Title.find(params[:id]).to_json(include: [:title_creators, :title_dates, :title_original_identifiers, :title_publishers, :title_genres, :title_forms, :title_locations])
    #render :json => @title
    render partial: 'ajax_show'
  end

  def autocomplete_title_for_collection

  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_title
    @title = Title.find(params[:id])
    @series = @title.series
  end

  def set_series
    @series = Series.find(params[:title][:series_id]) unless params[:title][:series_id].blank?
  end

  def set_all_title_cv
    set_form_cv
    set_genre_cv
    set_title_cv
  end
  def set_physical_object_cv
    @cv = ControlledVocabulary.physical_object_cv
    @l_cv = ControlledVocabulary.language_cv
    @pod_cv = ControlledVocabulary.physical_object_date_cv
  end
  def set_title_cv
    @title_cv = ControlledVocabulary.title_cv
  end
  def set_form_cv
    @form_cv = ControlledVocabulary.title_form_cv
  end
  def set_genre_cv
    @genre_cv = ControlledVocabulary.title_genre_cv
  end
  def set_creator_cv

  end

    # Never trust parameters from the scary internet, only allow the white list through.
    def title_params
      params.require(:title).permit(
          :title_text, :summary, :series_id, :series_title_index, :modified_by_id, :created_by_id, :series_part, :notes,
          title_creators_attributes: [:id, :name, :role, :_destroy],
          title_dates_attributes: [:id, :date, :date_type, :_destroy],
          title_genres_attributes: [:id, :genre, :_destroy],
          title_original_identifiers_attributes: [:id, :identifier, :identifier_type, :_destroy],
          title_publishers_attributes: [:id, :name, :publisher_type, :_destroy],
          title_forms_attributes: [:id, :form, :_destroy],
          title_locations_attributes: [:id, :location, :_destroy]
      )
    end
end
