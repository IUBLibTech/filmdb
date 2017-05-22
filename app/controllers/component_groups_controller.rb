class ComponentGroupsController < ApplicationController
  include AlfHelper

  before_action :set_component_group, only:
		[:show, :edit, :update, :destroy, :ajax_physical_objects_list,
		 :remove_physical_object, :add_physical_objects, :ajax_queue_pull_request, :ajax_edit_summary]

  # GET /component_groups
  # GET /component_groups.json
  def index
    @component_groups = ComponentGroup.all
  end

  # GET /component_groups/1
  # GET /component_groups/1.json
  def show
  end

  # GET /component_groups/new
  def new
    @component_group = ComponentGroup.new
  end

  # GET /component_groups/1/edit
  def edit
  end

  # POST /component_groups
  # POST /component_groups.json
  def create
    @component_group = ComponentGroup.new(component_group_params)
    respond_to do |format|
      if @component_group.save
        format.html { redirect_to @component_group, notice: 'Component group was successfully created.' }
        format.json { render :show, status: :created, location: @component_group }
      else
        format.html { render :new }
        format.json { render json: @component_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /component_groups/1
  # PATCH/PUT /component_groups/1.json
  def update
    respond_to do |format|
      if @component_group.update(component_group_params)
        format.html { redirect_to @component_group, notice: 'Component group was successfully updated.' }
        format.json { render :show, status: :ok, location: @component_group }
      else
        format.html { render :edit }
        format.json { render json: @component_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /component_groups/1
  # DELETE /component_groups/1.json
  def destroy
    @component_group.destroy
    respond_to do |format|
      format.html { redirect_to :back, notice: 'Component group was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def ajax_queue_pull_request
    result = pull_request([@component_group.id])
    render text: result, status: (result == "failure" ? 500 : 200)
  end

  def ajax_physical_objects_list
    render partial: 'ajax_physical_objects_list'
  end

  def ajax_edit_summary
		update = params[:cg_summary_edit][:summary]
		@component_group.update_attributes(group_summary: update)
		render text: "success"
  end

  # place holder for ajax form to submit change to a component groups summary text
  def cg_summary_edit
    ''
  end

  def add_physical_objects
    params[:cg_pos][:po_ids].split(',').collect { |p| p.to_i }.each do |po_id|
      ComponentGroupPhysicalObject.transaction do
        if !@component_group.physical_objects.exists?(po_id)
          ComponentGroupPhysicalObject.new(physical_object_id: po_id, component_group_id: @component_group.id).save
        end
      end
    end

    respond_to do |format|
      format.html { redirect_to title_path(@component_group.title.id), notice: "Physical Objects successfully added to Component Group"}
    end
  end

  def remove_physical_object
    if @component_group.physical_objects.exists?(params[:pid])
      ComponentGroupPhysicalObject.where(physical_object_id: params[:pid], component_group_id: @component_group.id).delete_all
      @msg = "Physical Object removed from Component Group"
    else
      @msg = "The specified Physical Object does not belong to this Component Group"
    end
    respond_to do |format|
      format.html { redirect_to title_path(@component_group.title.id), notice: @msg }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_component_group
      @component_group = ComponentGroup.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def component_group_params
      params.fetch(:component_group, {})
    end
end
