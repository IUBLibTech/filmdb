# this controller is responsible for moving physical objects through the workflow. Each workflow state is comprised of
# a pair of of controller actions; one action to display all physical objects currently in that state, and a second action to
# provide ajax functionality to move individual physical objects on to the next workflow state
class WorkflowController < ApplicationController
	include AlfHelper

	before_action :set_physical_object, only: [:process_receive_from_storage, :process_return_to_storage ]
	before_action :set_onsite_pos, only: [:send_for_mold_abatement,
																				:process_send_for_mold_abatement, :receive_from_storage, :process_receive_from_storage,
																				:send_to_freezer, :process_send_to_freezer]
	before_action :set_po, only: [:process_return_to_storage, :process_send_for_mold_abatement, :process_send_to_freezer, :process_mark_missing]


	def pull_request
		@physical_objects = PhysicalObject.where_current_workflow_status_is(WorkflowStatus::QUEUED_FOR_PULL_REQUEST)
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
						ws = WorkflowStatus.build_workflow_status(WorkflowStatus::PULL_REQUESTED, p)
						p.workflow_statuses << ws
						p.save!
					end
					push_pull_request(pos)
					flash[:notice] = "Storage has been notified to pull #{pos.size} records."
				end
			rescue Exception => e
				logger.error e.message
				logger.error e.backtrace.join('\n')
				flash[:warning] = "An error occured when trying to push the request to the ALF system: #{e.message} (see log files for full details)"
			end
		end
		redirect_to :pull_request
	end

	def ajax_cancel_queued_pull_request
		@physical_object = PhysicalObject.where(id: params[:id]).first
		if @physical_object.nil?
			flash.now[:warning] = "Couldn't find physical object with ID #{params[:id]}"
		elsif @physical_object.current_workflow_status.status_name != WorkflowStatus::QUEUED_FOR_PULL_REQUEST
			flash.now[:warning] = "#{@physical_object.iu_barcode} is not currently queued for a pull request"
		else
			PhysicalObject.transaction do
				@physical_object.active_component_group.physical_objects.each do |p|
					p.workflow_statuses << WorkflowStatus.build_workflow_status(p.storage_location, p)
					p.active_component_group = nil
					p.save
				end
			end
			all = @physical_object.active_component_group.physical_objects
			others = all.reject{ |po| po.iu_barcode == @physical_object.iu_barcode}.collect{ |po| po.iu_barcode}.join(', ')
			if all.size > 1
				flash.now[:notice] = "#{@physical_object.iu_barcode} was returned to storage. Additionally, #{others} #{others.size > 2 ? 'were' : 'was'} part of the pull request and have also been returned to storage"
			else
				flash.now[:notice] = "#{@physical_object.iu_barcode} was returned to storage."
			end
		end
		render json: all.collect{ |p| p.iu_barcode }
	end

	def receive_from_storage
		@physical_objects = PhysicalObject.where_current_workflow_status_is(WorkflowStatus::PULL_REQUESTED)
	end
	# this action handles the beginning of ALF workflow
	def process_receive_from_storage
		if @physical_object.nil?
			flash[:warning] = "Could not find Physical Object with IU Barcode: #{params[:physical_object][:iu_barcode]}"
		elsif !@physical_object.in_transit_from_storage?
			flash[:warning] = "#{@physical_object.iu_barcode} has not been Requested From Storage. It is currently: #{@po.current_workflow_status.type_and_location}"
		elsif @physical_object.current_workflow_status.valid_next_workflow?(params[:physical_object][:workflow]) && @physical_object.active_component_group.whose_workflow != WorkflowStatus::MDPI
			flash[:warning] = "#{@physical_object.iu_barcode} should have been delivered to Wells 052, Component Group type: #{@physical_object.active_component_group.group_type}"
		elsif @physical_object.footage.blank? && params[:physical_object][:footage].blank?
			flash[:warning] = "You must specify footage for #{@physical_object.iu_barcode}"
		elsif !@physical_object.current_workflow_status.valid_next_workflow?(params[:physical_object][:workflow])
			flash[:warning] = "#{@physical_object.iu_barcode} cannot be moved to status: #{params[:physical_object][:workflow]}. "+
				"It's current status [#{@physical_object.current_workflow_status.type_and_location}] does not allow that."
		else
			ws = WorkflowStatus.build_workflow_status(params[:physical_object][:workflow], @physical_object)
			@physical_object.workflow_statuses << ws
			@physical_object.footage = params[:physical_object][:footage] unless params[:physical_object][:footage].blank?
			if WorkflowStatus::STATUS_TYPES_TO_STATUSES['Storage'].include? params[:physical_object][:workflow]
				@physical_object.active_component_group = nil
			end
			@physical_object.save
			flash[:notice] = "#{@physical_object.iu_barcode} has been marked: #{ws.type_and_location}"
		end
		redirect_to :receive_from_storage
	end

	def ajax_alf_receive_iu_barcode
		@physical_object = PhysicalObject.where(iu_barcode: params[:iu_barcode]).first
		if @physical_object.nil?
			@msg = "Could not find a record with barcode: #{params[:iu_barcode]}"
		elsif !@physical_object.in_transit_from_storage?
			@msg = "Error: #{@physical_object.iu_barcode} has not been Requested From Storage. Current Workflow status/location: #{@physical_object.current_workflow_status.type_and_location}"
		end
		render partial: 'ajax_alf_receive_iu_barcode'
	end

	# this action processes recieved from storage at Wells
	def process_receive_from_storage_wells
		@physical_object = PhysicalObject.where(iu_barcode: params[:physical_object][:iu_barcode]).first
		if @physical_object.nil?
			flash.now[:warning] = "Could not find Physical Object with barcode #{params[:physical_object][:iu_barcode]}"
		elsif @physical_object.current_workflow_status.whose_workflow != WorkflowStatus::IULMIA
			flash.now[:warning] = "#{@physical_object.iu_barcode} is not assigned to IULMIA-Wells workflow. It was pulled for #{@physical_object.active_component_group.group_type}"
		elsif !@physical_object.current_workflow_status.valid_next_workflow?(WorkflowStatus::IN_WORKFLOW_WELLS)
			flash.now[:warning] = "#{@physical_object.iu_barcode} cannot be received. Its current workflow status is #{@physical_object.current_workflow_status.type_and_location}"
		else
			ws = WorkflowStatus.build_workflow_status(WorkflowStatus::IN_WORKFLOW_WELLS, @physical_object)
			@physical_object.workflow_statuses << ws
			@physical_object.save
			others = @physical_object.waiting_active_component_group_members?
			if others
				others = others.collect{ |p| p.iu_barcode }.join(', ')
			end
			flash.now[:notice] = "#{@physical_object.iu_barcode} workflow status was updated to <b>#{WorkflowStatus::IN_WORKFLOW_WELLS}</b> "+
				"#{others ? " #{others} are also part of this objects pull request and have not yet been received at Wells" : ''}".html_safe
		end
		@physical_objects = PhysicalObject.where_current_workflow_status_is(WorkflowStatus::PULL_REQUESTED)
		redirect_to :receive_from_storage
	end

	def return_to_storage
		@physical_objects = PhysicalObject.where_current_workflow_status_is(WorkflowStatus::JUST_INVENTORIED_WELLS, WorkflowStatus::QUEUED_FOR_PULL_REQUEST, WorkflowStatus::PULL_REQUESTED)
	end
	def process_return_to_storage
		ws = WorkflowStatus.build_workflow_status(@po.storage_location, @po)
		@po.workflow_statuses << ws
		@po.active_component_group = nil?
		@po.save
		flash[:notice] = "#{@po.iu_barcode} was returned to #{ws.status_name}"
		redirect_to :return_to_storage
	end

	def send_for_mold_abatement
	end

	def process_send_for_mold_abatement
		ws = WorkflowStatus.build_workflow_status(WorkflowStatus::MOLD_ABATEMENT, @po)
		@po.workflow_statuses << ws
		@po.save
		flash.now[:notice] = "#{@po.iu_barcode} has been sent to #{WorkflowStatus::MOLD_ABATEMENT}"
		render :send_for_mold_abatement
	end

	def send_to_freezer
	end
	def process_send_to_freezer
		ws = WorkflowStatus.new(WorkflowStatus::IN_FREEZER, @po)
		@po.workflow_statuses << ws
		@po.save
		flash.now[:notice] = "#{@po.iu_barcode}'s location has been updated to' #{WorkflowStatus::IN_FREEZER}"
		render :send_to_freezer
	end

	def mark_missing
		@physical_objects = PhysicalObject.where_current_workflow_status_is(WorkflowStatus::MISSING)
	end
	def process_mark_missing
		ws = WorkflowStatus.build_workflow_status(WorkflowStatus::MISSING, @po)
		@po.workflow_statuses << ws
		@po.save
		flash.now[:notice] = "#{@po.iu_barcode} has been marked #{WorkflowStatus::MISSING}"
		@physical_objects = PhysicalObject.where_current_workflow_status_is(WorkflowStatus::MISSING)
		render :mark_missing
	end

	def receive_from_external
		@physical_objects = PhysicalObject.where_current_workflow_status_is(WorkflowStatus::SHIPPED_EXTERNALLY)
		@action_text = 'Returned From External'
		@url = '/workflow/ajax/received_external/'
	end

	private
	def set_physical_object
		@physical_object = PhysicalObject.where(iu_barcode: params[:physical_object][:iu_barcode]).first
	end

	def set_onsite_pos
		@physical_objects = []
	end
	def set_po
		@po = PhysicalObject.where(iu_barcode: params[:physical_object][:iu_barcode]).first
	end


end
