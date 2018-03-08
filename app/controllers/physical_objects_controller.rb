class PhysicalObjectsController < ApplicationController
  require 'manual_roll_back_error'

  include PhysicalObjectsHelper
  include MailHelper

  before_action :set_physical_object, only: [:show, :show_xml, :edit, :update, :destroy, :mark_missing]
  before_action :set_cv, only: [:new_physical_object, :create, :edit, :update, :new, :edit_ad_strip, :update_ad_strip,
                                :edit_location, :update_location, :duplicate
  ]

  # GET /physical_objects
  # GET /physical_objects.json
  def index
		@statuses = WorkflowStatus::ALL_STATUSES.collect{ |t| [t, t]}
	  if params[:status] && !params[:status].blank?
      @count = PhysicalObject.count_where_current_workflow_status_is(params[:digitized], params[:status])
      if @count > PhysicalObject.per_page
        @paginate = true
        @page = (params[:page].nil? ? 1 : params[:page].to_i)
        @physical_objects = PhysicalObject.where_current_workflow_status_is((@page - 1) * PhysicalObject.per_page, PhysicalObject.per_page, params[:digitized], params[:status])
      else
        @physical_objects = PhysicalObject.where_current_workflow_status_is(nil, nil, params[:digitized], params[:status])
      end
    elsif params[:status] == ''
      @count = (params[:digitized] ? PhysicalObject.where(digitized: true).size : PhysicalObject.all.size)
      @page = (params[:page].nil? ? 1 : params[:page].to_i)
      @paginate = true
		  @physical_objects = (params[:digitized] ?
         PhysicalObject.where(digitized: true).offset((@page - 1) * PhysicalObject.per_page).limit(PhysicalObject.per_page) :
         PhysicalObject.all.offset((@page - 1) * PhysicalObject.per_page).limit(PhysicalObject.per_page)
      )
    else
      @physical_objects = []
	  end
  end

  # GET /physical_objects/1
  # GET /physical_objects/1.json
  def show
    if session[:physical_object_create_action]
      @continue_url = session[:physical_object_create_action]
      @continue_text = ''
      pattern = /([0-9]+)/
      id = pattern.match(@continue_url) ? pattern.match(@continue_url)[0] : nil
      if @continue_url == new_physical_object_path
        @continue_text = "Continue Creating New Physical Objects"
      elsif @continue_url.include?('collection')
        collection = Collection.find(id)
        @continue_text = "Continue Inventorying Collection <i>#{collection.name}</i>".html_safe
      elsif @continue_url.include?('series')
        series = Series.find(id)
        @continue_text = "Continue Inventorying Series <i>#{series.title}</i>".html_safe
      elsif @continue_url.include?('title')
        title = Title.find(id)
        @continue_text = "Continue Inventorying Title <i>#{title.title_text}</i>".html_safe
      end
    end
    session[:physical_object_create_action] = nil
  end

  def show_xml
    xml = Builder::XmlMarkup.new(indent: 2)
    xml.instruct! :xml, :version=>"1.0"
    @physical_object.to_xml(xml)
    render xml: xml.target!
  end

  # GET /physical_objects/new_physical_object
  def new
    u = User.current_user_object
    @physical_object = PhysicalObject.new(inventoried_by: u.id, modified_by: u.id)
    render 'new_physical_object'
  end

  # GET /physical_objects/1/edit
  def edit
    @em = 'Editing Physical Object'
    @physical_object = PhysicalObject.find(params[:id])
    @physical_object.modified_by = User.current_user_object.id
    if @physical_object.nil?
      flash.now[:warning] = "No such physical object..."
      redirect_to :back
    end
  end

  # POST /physical_objects
  # POST /physical_objects.json
  def create
    create_physical_object
  end

  # PATCH/PUT /physical_objects/1
  # PATCH/PUT /physical_objects/1.json
  def update
    nitrate = @physical_object.base_nitrate
    respond_to do |format|
      begin
        PhysicalObject.transaction do
          # check to see if titles have changed in the update
          process_titles
          @physical_object.modifier = User.current_user_object
          @success = @physical_object.update_attributes!(physical_object_params)
        end
      rescue Exception => error
        logger.debug $!
      end
      if @success
        if @physical_object.base_nitrate and !nitrate
          notify_nitrate(@physical_object)
        end
        format.html { redirect_to @physical_object, notice: 'Physical object was successfully updated.' }
        format.json { render :show, status: :ok, location: @physical_object }
      else
        format.html { render :edit }
        format.json { render json: @physical_object.errors, status: :unprocessable_entity }
      end
    end
  end


  def duplicate
    @em = 'Duplicating Physical Object'
    @physical_object = PhysicalObject.find(params[:id]).dup
    @physical_object.iu_barcode = nil
    @physical_object.reel_number = nil
    respond_to do |format|
      format.html { render 'new_physical_object', notice: 'Physical Object was successfully duplicated.' }
    end
  end

  def create_duplicate
    create_physical_object
  end

  def edit_ad_strip
    @physical_object = PhysicalObject.new
  end

  def update_ad_strip
    bc = params[:physical_object][:iu_barcode]
    adv = params[:physical_object][:ad_strip]
    @physical_object = PhysicalObject.where(iu_barcode: bc).first
    if @physical_object.nil?
      flash[:warning] = "No Physical Object with Barcode #{bc} Could Be Found!".html_safe
    else
      nitrate = @physical_object.base_nitrate
      @physical_object.update_attributes(ad_strip: adv)
      flash[:notice] = "Physical Object [#{bc}] was updated with AD Strip Value: #{adv}"
      if @physical_object.base_nitrate && !nitrate
        notify_nitrate(@physical_object)
      end
    end
    redirect_to edit_ad_strip_path
  end

  def mark_missing
    if @physical_object.current_workflow_status.status_name == WorkflowStatus::PULL_REQUESTED
      ws = WorkflowStatus.build_workflow_status(WorkflowStatus::MISSING, @physical_object, true)
      @physical_object.workflow_statuses << ws
      @physical_object.save
      flash[:notice] = "#{@physical_object.iu_barcode} was successfully marked <i>Missing</i>".html_safe
      redirect_to physical_objects_path
    else
      flash[:warning] = "#{@physical_object.iu_barcode}'s workflow status must be Pull Requested to mark missing. It's current status is #{@physical_object.current_workflow_status.status_name}".html_safe
      redirect_to physical_objects_path
    end
  end

  def workflow_history
    @physical_object = PhysicalObject.find(params[:id])
  end

  # DELETE /physical_objects/1
  # DELETE /physical_objects/1.json
  def destroy
    authorize PhysicalObject
    @physical_object.destroy
    respond_to do |format|
      format.html { redirect_to physical_objects_url, notice: 'Physical object was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def ajax_show_storage
    po = PhysicalObject.where(iu_barcode: params[:iu_barcode]).first
    if po.nil?
      render text: "Could Not Find Physical Object With IU Barcode: #{params[:iu_barcode]}"
    else
      render text: "#{params[:iu_barcode]} Should Be Returned to: <b>#{(po.storage_location.blank? ? "<b><i>Object Just inventoried...</i><b>" : po.storage_location)}</b>".html_safe
    end
  end

  # and ajax call to determine if a given IU barcoded physical object exists, and belongs to the specified title
  # call should come in with iu_barcode and title_id params
  def ajax_belongs_to_title?
    po = PhysicalObject.where(iu_barcode: params[:iu_barcode]).first
    title = Title.where(id: params[:title_id]).first
    render json: [!po.nil?, (po.nil? || !po.titles.include?(title) ? false : po.id)]
  end

  def ajax_lookup_barcode
    po = PhysicalObject.find(params[:id])
    render text: po.iu_barcode
  end

  def digiprovs
    @physical_object = PhysicalObject.find(params[:id])
    @dp = Digiprov.where(physical_object_id: params[:id])
  end

  def test_email
    @success = true
    begin
      test
    rescue Exception
      logger.debug $!
      @success = false
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_physical_object
    @physical_object = PhysicalObject.find(params[:id])
  end

  def set_cv
    @cv = ControlledVocabulary.physical_object_cv
    @l_cv = ControlledVocabulary.language_cv
    @pod_cv = ControlledVocabulary.physical_object_date_cv
  end

  def page_link_path(page)
	  physical_objects_path(page: page, status: params[:status], digitized: params[:digitized])
  end
  helper_method :page_link_path

end
