class PhysicalObjectsController < ApplicationController
  include PhysicalObjectsHelper

  before_action :set_physical_object, only: [:show, :edit, :update, :destroy]
  before_action :set_series, only: [:new_physical_object, :create, :edit, :update]

  # GET /physical_objects
  # GET /physical_objects.json
  def index
    @physical_objects = PhysicalObject.all
  end

  # GET /physical_objects/1
  # GET /physical_objects/1.json
  def show
  end

  # GET /physical_objects/new_physical_object
  def new
    u = User.current_user_object
    @physical_object = PhysicalObject.new(inventoried_by: u.id, modified_by: u.id)
    @series = Series.all.order(:title)
    render 'new_physical_object'
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
    create_physical_object
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

    def set_series
      @series = Series.all.order(:title)
    end

end
