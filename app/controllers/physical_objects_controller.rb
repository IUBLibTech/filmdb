class PhysicalObjectsController < ApplicationController
  require 'manual_roll_back_error'

  include PhysicalObjectsHelper
  include MailHelper

  before_action :set_physical_object, only: [:show, :edit, :update, :destroy]
  before_action :set_cv, only: [:new_physical_object, :create, :edit, :update, :new, :edit_ad_strip, :update_ad_strip,
                                :edit_location, :update_location, :duplicate
  ]

  # GET /physical_objects
  # GET /physical_objects.json
  def index
    @physical_objects = PhysicalObject.all
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

  def edit_location
    @physical_object = PhysicalObject.new
  end

  def update_location
    bc = params[:physical_object][:iu_barcode]
    location = params[:physical_object][:location]
    @physical_object = PhysicalObject.where(iu_barcode: bc).first
    if @physical_object.nil?
      flash[:warning] = "No Physical Object with Barcode #{bc} Could Be Found!".html_safe
    else
      @physical_object.update_attributes(location: location)
      flash[:notice] = "Physical Object [#{bc}] was updated with new location: #{location}"
    end
    redirect_to edit_location_path
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

end
