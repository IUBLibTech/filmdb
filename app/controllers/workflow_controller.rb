# this controller is responsible for moving physical objects through the workflow. Each workflow state is comprised of
# a pair of of controller actions; one action to display all physical objects currently in that state, and a second action to
# provide ajax functionality to move individual physical objects on to the next workflow state
class WorkflowController < ApplicationController

	before_action :set_physical_object, only: [:process_receive_from_storage, :process_return_to_storage ]
	before_action :set_onsite_pos, only: [:return_to_storage, :process_return_to_storage, :send_for_mold_abatement,
																				:process_send_for_mold_abatement, :receive_from_storage, :process_receive_from_storage,
																				:send_to_freezer, :process_send_to_freezer]
	before_action :set_po, only: [:process_return_to_storage, :process_send_for_mold_abatement, :process_send_to_freezer, :process_mark_missing]


	def pull_request
		@physical_objects = PhysicalObject.where_current_workflow_status_is(WorkflowStatusTemplate::PULL_REQUEST_QUEUED)
	end
	def process_pull_requested
		ids = params[:ids]
		if ids.blank?
			flash[:warning] = 'You did not specify any Physical Objects to pull'
		else
			ids = ids.split(',')
			pos = PhysicalObject.where(id: ids)
			bad_req = []
			begin
				PhysicalObject.transaction do
					pos.each do |p|
						cw = p.current_workflow_status
						if cw.status_type != WorkflowStatusTemplate::PULL_REQUEST_QUEUED
							bad_req.push(p.iu_barcode)
						else
							ws = WorkflowStatus.new(
								workflow_status_template_id: WorkflowStatusTemplate::STATUS_TO_TEMPLATE_ID[WorkflowStatusTemplate::PULL_REQUESTED],
								physical_object_id: p.id,
								workflow_status_location_id: cw.workflow_status_location_id
							)
							p.workflow_statuses << ws
						end
					end
					if bad_req.size > 0
						flash[:warning] = "The following Physical Objects are note Queued for Pull Requests: #{bad_req.join(', ')}"
						raise ManualRollBackError "Some physical objects were not in proper state to make pull request"
					else
						flash[:notice] = "Storage has been notified to pull #{pos.size} records."
					end
				end
				# FIXME: write the ALF file to their directory

			# only want to catch this type of error, everything else is something unintentially wrong
			rescue ManualRollBackError => e
			end
		end
		redirect_to :pull_request
	end

	def receive_from_storage
		@physical_objects = PhysicalObject.where_current_workflow_status_is(WorkflowStatusTemplate::PULL_REQUESTED)
	end
	def process_receive_from_storage
		if @physical_object.nil?
			flash[:warning] = "Could not find Physical Object with IU Barcode: #{params[:physical_object][:iu_barcode]}"
		elsif !@physical_object.in_transit_from_storage?
			flash[:warning] = "#{@physical_object.iu_barcode} has not been Requested From Storage. It is currently: #{@po.current_workflow_status.type_and_location}"
		else
			ws = WorkflowStatus.new(
				physical_object_id: @physical_object,
				workflow_status_template_id: WorkflowStatusTemplate::STATUS_TO_TEMPLATE_ID[WorkflowStatusTemplate::ON_SITE],
				workflow_status_location_id: WorkflowStatusLocation.digi_prep_location_id
			)
			@physical_object.workflow_statuses << ws
			@physical_object.save
			flash[:notice] = "#{@physical_object.iu_barcode} has been marked received and updated to location: #{ws.type_and_location}"
		end
		redirect_to :receive_from_storage
	end

	def return_to_storage
	end
	def process_return_to_storage
		ws = WorkflowStatus.new(
			workflow_status_template_id: WorkflowStatusTemplate::STATUS_TO_TEMPLATE_ID[WorkflowStatusTemplate::IN_STORAGE],
			physical_object_id: @po.id,
			workflow_status_location_id: params[:physical_object][:location_id]) unless @po.nil?
		if update_onsite(ws)
			location = WorkflowStatusLocation.find(params[:physical_object][:location_id])
			flash[:notice] = "#{@po.iu_barcode} was returned to #{ws.type_and_location}"
		end
		redirect_to :return_to_storage
	end

	def send_for_mold_abatement
	end

	def process_send_for_mold_abatement
		if @po.current_workflow_status.workflow_status_location.id == WorkflowStatusLocation.mold_abatement_location_id
			flash.now[:warning] = "#{@po.iu_barcode} has already been sent for mold abatement!"
		else
			location = WorkflowStatusLocation.mold_abatement_location
			ws = WorkflowStatus.new(
				workflow_status_template_id: WorkflowStatusTemplate::STATUS_TO_TEMPLATE_ID[WorkflowStatusTemplate::ON_SITE],
				physical_object_id: @po.id,
				workflow_status_location_id: location.id)
			if update_onsite(ws) == true
				flash.now[:notice] = "#{@po.iu_barcode} has been updated to #{ws.type_and_location}"
			end
		end
		render :send_for_mold_abatement
	end

	def send_to_freezer
	end
	def process_send_to_freezer
		if @po.current_workflow_status.workflow_status_location.id == WorkflowStatusLocation.freezer_location_id
			flash.now[:warning] = "#{@po.iu_barcode} has already been sent to the freezer!"
		else
			location = WorkflowStatusLocation.freezer_location
			ws = WorkflowStatus.new(workflow_status_template_id: WorkflowStatusTemplate::STATUS_TO_TEMPLATE_ID[WorkflowStatusTemplate::ON_SITE], physical_object_id: @po.id, workflow_status_location_id: location.id)
			if update_onsite(ws) == true
				flash.now[:notice] = "#{@po.iu_barcode} has been updated to #{ws.type_and_location}"
			end
		end
		render :send_to_freezer
	end

	def mark_missing
		@physical_objects = PhysicalObject.where_current_workflow_status_is(WorkflowStatusTemplate::MISSING)
	end
	def process_mark_missing
		if @po.current_workflow_status.workflow_status_template.id == WorkflowStatusTemplate::STATUS_TO_TEMPLATE_ID[WorkflowStatusTemplate::MISSING]
			flash.now[:warning] = "#{@po.iu_barcode} has already been marked Missing!"
		else
			location = @po.current_workflow_status.workflow_status_location
			ws = WorkflowStatus.new(workflow_status_template_id: WorkflowStatusTemplate::STATUS_TO_TEMPLATE_ID[WorkflowStatusTemplate::MISSING], physical_object_id: @po.id, workflow_status_location_id: location.id)
			@po.workflow_statuses << ws
			@po.save
			flash.now[:notice] = "#{@po.iu_barcode} has been updated to #{ws.type_and_location}"
		end
		@physical_objects = PhysicalObject.where_current_workflow_status_is(WorkflowStatusTemplate::MISSING)
		render :mark_missing
	end

	def receive_from_external
		@physical_objects = PhysicalObject.where_current_workflow_status_is(WorkflowStatusTemplate::SHIPPED_TO_EXTERNAL)
		@action_text = 'Returned From External'
		@url = '/workflow/ajax/received_external/'
	end

	private
	def set_physical_object
		@physical_object = PhysicalObject.where(iu_barcode: params[:physical_object][:iu_barcode]).first
	end

	def set_onsite_pos
		@physical_objects = PhysicalObject.where_current_workflow_status_is(WorkflowStatusTemplate::ON_SITE)
	end
	def set_po
		@po = PhysicalObject.where(iu_barcode: params[:physical_object][:iu_barcode]).first
	end

	# returns true if the object is ON_SITE and updated to the specified workflow status, or sets a global @err message if the action could not be taken
	def update_onsite(workflow_status)
		if @po.nil?
			flash.now[:warning] = "Could not find object with barcode: #{params[:physical_object][:iu_barcode]}".html_safe
			return false
		else
			if @po.current_workflow_status.status_type != WorkflowStatusTemplate::ON_SITE
				flash.now[:warning] = "#{@po.iu_barcode} is not <i>On Site</i>, it is: #{@po.current_workflow_status.type_and_location}".html_safe
				return false
			else
				@po.workflow_statuses << workflow_status
				@po.save
			end
		end
	end

end
