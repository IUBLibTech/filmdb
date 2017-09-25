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
    @component_group.scan_resolution(params['2k'] ? '2k' : (params['4k'] ? '4k' : '5k'))
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
	      # currently, the only place a CG can be updated is on the Titles page so redirect there
        format.html { redirect_to @component_group.title, notice: 'Component group was successfully updated.' }
        format.json { render :show, status: :ok, location: @component_group }
      else
        format.html { render :edit }
        format.json { render json: @component_group.errors, status: :unprocessable_entity }
      end
    end
  end

  def on_site

  end

  # DELETE /component_groups/1
  # DELETE /component_groups/1.json
  def destroy
    authorize ComponentGroup
    @component_group.destroy
    respond_to do |format|
      format.html { redirect_to :back, notice: 'Component group was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def ajax_queue_pull_request
    # result = pull_request([@component_group.id])
    # render text: result, status: (result == "failure" ? 500 : 200)
    @component_group = ComponentGroup.find(params[:id])
    bad = {}
    begin
      PhysicalObject.transaction do
        @component_group.physical_objects.each do |p|
          status = p.current_workflow_status
          if !status.can_be_pulled?
            bad[p.id] = "#{p.iu_barcode} in not <i>In Storage</i> it is: <b>#{status.status_name}</b>".html_safe
          else
            # must set active component group BEFORE building the next workflow status, WorkflowStatus needs to set the component group id on it
            p.active_component_group = @component_group
            ws = WorkflowStatus.build_workflow_status(WorkflowStatus::QUEUED_FOR_PULL_REQUEST, p)
            p.workflow_statuses << ws
	          p.save!
          end
        end
        if bad.size > 0
          raise ManualRollBackError.new()
        else
          render text: 'success'
        end
      end
    rescue ManualRollBackError => e
      render json: bad.to_json
    end
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
          ComponentGroupPhysicalObject.new(physical_object_id: po_id, component_group_id: @component_group.id).save!
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
      params.require(:component_group).permit(
        :scan_resolution, :color_space, :return_on_reel, :clean
      )
    end
end
