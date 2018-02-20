# this controller is responsible for moving physical objects through the workflow. Each workflow state is comprised of
# a pair of of controller actions; one action to display all physical objects currently in that state, and a second action to
# provide ajax functionality to move individual physical objects on to the next workflow state
class WorkflowController < ApplicationController
	include AlfHelper
	include WorkflowHelper

	before_action :set_physical_object, only: [:process_receive_from_storage, :process_return_to_storage ]
	before_action :set_onsite_pos, only: [:send_for_mold_abatement,
																				:process_send_for_mold_abatement, :receive_from_storage, :process_receive_from_storage,
																				:send_to_freezer, :process_send_to_freezer]
	before_action :set_po, only: [:process_return_to_storage, :process_send_for_mold_abatement, :process_send_to_freezer, :process_mark_missing]


	def pull_request
		@physical_objects = PhysicalObject.joins(:active_component_group).where_current_workflow_status_is(nil, nil, WorkflowStatus::QUEUED_FOR_PULL_REQUEST)
		@ingested = []
		@not_ingested = []
		@best_copy_alf_count = 0
		@best_copy_wells_count = 0
		@physical_objects.each do |p|
			if p.storage_location == WorkflowStatus::IN_STORAGE_INGESTED
				@ingested << p
			else
				@not_ingested << p
			end
			if p.active_component_group.group_type == ComponentGroup::BEST_COPY_MDPI_WELLS
				@best_copy_wells_count += 1
			elsif p.active_component_group.group_type == ComponentGroup::BEST_COPY_ALF
				@best_copy_alf_count += 1
			end
		end
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
					@pr = push_pull_request(pos, User.current_user_object)
					flash[:notice] = "Storage has been notified to pull #{@pr.automated_pull_physical_objects.size} records."
				end
			rescue Exception => e
				#logger.error e.message
				#logger.error e.backtrace.join("\n")
				puts e.message
				puts e.backtrace.join("\n")
				flash[:warning] = "An error occurred when trying to push the request to the ALF system: #{e.message} (see log files for full details)"
			end
		end
		if @pr
			redirect_to show_pull_request_path(@pr)
		else
			redirect_to :pull_request
		end
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
		@physical_objects = []#PhysicalObject.where_current_workflow_status_is(nil, nil, WorkflowStatus::PULL_REQUESTED)
		u = User.current_user_object
		if u.worksite_location == 'ALF'
			@alf = true
		else
			@wells = true
		end
	end
	# this action handles the beginning of ALF workflow
	def process_receive_from_storage
		if @physical_object.nil?
			flash[:warning] = "Could not find Physical Object with IU Barcode: #{params[:physical_object][:iu_barcode]}"
		elsif !@physical_object.in_transit_from_storage? && @physical_object.current_workflow_status.status_name != WorkflowStatus::MOLD_ABATEMENT && @physical_object.current_workflow_status.status_name != WorkflowStatus::WELLS_TO_ALF_CONTAINER
			flash[:warning] = "#{@physical_object.iu_barcode} has not been Requested From Storage. It is currently: #{@po.current_workflow_status.type_and_location}"
		elsif @physical_object.current_workflow_status.valid_next_workflow?(params[:physical_object][:workflow]) && @physical_object.active_component_group.deliver_to_wells?
			flash[:warning] = "#{@physical_object.iu_barcode} should have been delivered to Wells 052, Component Group type: #{@physical_object.active_component_group.group_type}"
		elsif @physical_object.footage.blank? && params[:physical_object][:footage].blank? && @physical_object.active_component_group.group_type != ComponentGroup::BEST_COPY_ALF
			flash[:warning] = "You must specify footage for #{@physical_object.iu_barcode}"
		elsif !@physical_object.current_workflow_status.valid_next_workflow?(params[:physical_object][:workflow])
			flash[:warning] = "#{@physical_object.iu_barcode} cannot be moved to status: #{params[:physical_object][:workflow]}. "+
				"It's current status [#{@physical_object.current_workflow_status.type_and_location}] does not allow that."
		else
			ws = WorkflowStatus.build_workflow_status(params[:physical_object][:workflow], @physical_object)
			@physical_object.workflow_statuses << ws
			@physical_object.footage = params[:physical_object][:footage] unless params[:physical_object][:footage].blank?
			@physical_object.can_size = params[:physical_object][:can_size] unless params[:physical_object][:can_size].blank?
			@physical_object.save
			flash[:notice] = "#{@physical_object.iu_barcode} has been marked: #{ws.type_and_location}"
		end
		redirect_to :receive_from_storage
	end

	def ajax_alf_receive_iu_barcode
		@physical_object = PhysicalObject.where(iu_barcode: params[:iu_barcode]).first
		@cv = ControlledVocabulary.physical_object_cv
		if @physical_object.nil?
			@msg = "Could not find a record with barcode: #{params[:iu_barcode]}"
		elsif !@physical_object.in_transit_from_storage? && !@physical_object.current_workflow_status.status_name == WorkflowStatus::MOLD_ABATEMENT && !@physical_object.current_workflow_status.status_name == WorkflowStatus::WELLS_TO_ALF_CONTAINER
			@msg = "Error: #{@physical_object.iu_barcode} has not been Requested From Storage. Current Workflow status/location: #{@physical_object.current_workflow_status.type_and_location}"
		elsif @physical_object.active_component_group.deliver_to_wells?
			@msg = "Error: #{@physical_object.iu_barcode} should have been delivered to Wells. Please contact Amber/Andrew immediately"
		end
		render partial: 'ajax_alf_receive_iu_barcode'
	end

	def ajax_wells_receive_iu_barcode
		@physical_object = PhysicalObject.where(iu_barcode: params[:iu_barcode]).first
		@cv = ControlledVocabulary.physical_object_cv
		if @physical_object.nil?
			@msg = "Could not find physical object with IU barcode: #{params[:iu_barcode]}"
		elsif !@physical_object.in_transit_from_storage? || !@physical_object.current_location == WorkflowStatus::MOLD_ABATEMENT
			@msg = "Error: #{@physical_object.iu_barcode} cannot be received at Wells - its current location is #{@physical_object.current_location}"
		elsif @physical_object.active_component_group.deliver_to_alf?
			@msg = "#{@physical_object.iu_barcode} should have been delivered to ALF. It was pulled for: #{@physical_object.active_component_group.group_type}"
		end
		render partial: 'ajax_wells_receive_iu_barcode'
	end

	# this action processes recieved from storage at Wells
	def process_receive_from_storage_wells
		@physical_object = PhysicalObject.where(iu_barcode: params[:physical_object][:iu_barcode]).first
		if @physical_object.nil?
			flash.now[:warning] = "Could not find Physical Object with barcode #{params[:physical_object][:iu_barcode]}"
		elsif @physical_object.active_component_group.deliver_to_alf?
			flash.now[:warning] = "Error: #{@physical_object.iu_barcode} should have been delivered to ALF. It was pulled for #{@physical_object.active_component_group.group_type}. Please contact Amber/Andrew immediately."
		elsif !@physical_object.current_workflow_status.valid_next_workflow?(WorkflowStatus::BEST_COPY_MDPI_WELLS)
			flash.now[:warning] = "#{@physical_object.iu_barcode} cannot be received. Its current workflow status is #{@physical_object.current_workflow_status.type_and_location}"
		else
			ws = WorkflowStatus.build_workflow_status(WorkflowStatus::BEST_COPY_MDPI_WELLS, @physical_object)
			@physical_object.workflow_statuses << ws
			@physical_object.save
			others = @physical_object.waiting_active_component_group_members?
			if others
				others = others.collect{ |p| p.iu_barcode }.join(', ')
			end
			flash.now[:notice] = "#{@physical_object.iu_barcode} workflow status was updated to <b>#{WorkflowStatus::IN_WORKFLOW_WELLS}</b> "+
				"#{others ? " #{others} are also part of this objects pull request and have not yet been received at Wells" : ''}".html_safe
		end
		@physical_objects = []#PhysicalObject.where_current_workflow_status_is(nil, nil, WorkflowStatus::PULL_REQUESTED)
		redirect_to :receive_from_storage
	end

	def return_to_storage
		@physical_objects = []#PhysicalObject.where_current_workflow_status_is(nil, nil, WorkflowStatus::JUST_INVENTORIED_WELLS, WorkflowStatus::QUEUED_FOR_PULL_REQUEST, WorkflowStatus::PULL_REQUESTED)
	end
	def process_return_to_storage
		ws = WorkflowStatus.build_workflow_status(params[:physical_object][:location], @po)
		@po.workflow_statuses << ws
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
		ws = WorkflowStatus.build_workflow_status(WorkflowStatus::IN_FREEZER, @po)
		@po.workflow_statuses << ws
		@po.save
		flash.now[:notice] = "#{@po.iu_barcode}'s location has been updated to' #{WorkflowStatus::IN_FREEZER}"
		render :send_to_freezer
	end

	def mark_missing
		@physical_objects = []#PhysicalObject.where_current_workflow_status_is(nil, nil, WorkflowStatus::MISSING)
	end

	def process_mark_missing
		if @po.nil?
			flash[:warning] = "Could not find Physical Object with barcode #{params[:physical_object][:iu_barcode]}"
		else
			ws = WorkflowStatus.build_workflow_status(WorkflowStatus::MISSING, @po)
			@po.workflow_statuses << ws
			@po.save
			flash.now[:notice] = "#{@po.iu_barcode} has been marked #{WorkflowStatus::MISSING}"
			@physical_objects = []#PhysicalObject.where_current_workflow_status_is(nil, nil, WorkflowStatus::MISSING)
		end
		render :mark_missing
	end

	def receive_from_external
		@physical_objects = []#PhysicalObject.where_current_workflow_status_is(nil, nil, WorkflowStatus::SHIPPED_EXTERNALLY)
		@action_text = 'Returned From External'
		@url = '/workflow/ajax/received_external/'
	end

	# when items have been requested from ALF, it's possible that either ALF cannot find them or that someone else has the
	# item checked out already. This page lists all items in transit from storage and provides links to either cancel the
	# pull request (which puts the item back in storage), or to requeue the item so that it appears on the "Request Pull From Storage" page
	def cancel_after_pull_request
		@physical_objects = PhysicalObject.where_current_workflow_status_is(nil, nil, WorkflowStatus::PULL_REQUESTED)
	end

	def process_cancel_after_pull_request
		@physical_object = PhysicalObject.find(params[:id])
		if @physical_object.current_workflow_status.status_name != WorkflowStatus::PULL_REQUESTED
			flash.now[:warning] = "Physical Object #{@physical_object.iu_barcode} cannot be cancelled from a pull request. It's current status is: #{@physical_object.current_workflow_status.status_name}"
		else
			if @physical_object.same_active_component_group_members?
				flash[:notice] = "#{@physical_object.iu_barcode} was returned to storage [#{@physical_object.storage_location}] but belongs to a component group with other physical objects: "+
					"#{@physical_object.active_component_group.physical_objects.select{|p| p.iu_barcode != @physical_object.iu_barcode}.collect{|p| p.iu_barcode }.join(', ')}. They are still in active workflow."
			else
				flash[:notice] = "#{@physical_object.iu_barcode} was marked returned to storage [#{@physical_object.storage_location}]"
			end
			ws = WorkflowStatus.build_workflow_status(@physical_object.storage_location, @physical_object)
			ws.notes = 'Pull request cancelled after requested (most likely ALF reported the item missing or already checked out)'
			@physical_object.workflow_statuses << ws
			@physical_object.save
		end
		redirect_to cancel_after_pull_request_path
	end

	def process_requeue_after_pull_request
		@physical_object = PhysicalObject.find(params[:id])
		if @physical_object.current_workflow_status.status_name != WorkflowStatus::PULL_REQUESTED
			flash.now[:warning] = "Physical Object #{@physical_object.iu_barcode} cannot be cancelled from a pull request. It's current status is: #{@physical_object.current_workflow_status.status_name}"
		else
			ws = WorkflowStatus.build_workflow_status(WorkflowStatus::QUEUED_FOR_PULL_REQUEST, @physical_object, true)
			ws.notes = "#{@physical_object.iu_barcode} was requeued for pull request (most likely ALF reported the item missing or already checked out)"
			@physical_object.workflow_statuses << ws
			@physical_object.save
			if @physical_object.waiting_active_component_group_members?
				flash[:notice] = "#{@physical_object.iu_barcode} was marked #{@physical_object.current_workflow_status.status_name} but belongs to a component group with other physical objects: "+
					"#{@physical_object.active_component_group.physical_objects.select{|p| p.iu_barcode != self.iu_barcode}.join(', ')}. They are still in active workflow."
			else
				flash[:notice] = "#{@physical_object.iu_barcode} was marked #{@physical_object.current_workflow_status.status_name}"
			end
		end
		redirect_to cancel_after_pull_request_path
	end


	def best_copy_selection
		@physical_objects = []#PhysicalObject.where_current_workflow_status_is(nil, nil, WorkflowStatus::BEST_COPY_ALF, WorkflowStatus::BEST_COPY_MDPI_WELLS)
	end

	def ajax_best_copy_selection_barcode
		bc = params[:iu_barcode]
		@cg = nil
		@physical_object = PhysicalObject.where(iu_barcode: bc).first
		if @physical_object.nil?
			@msg = "Could not find Physical Object with IU Barcode: #{parms[:iu_barcode]}"
			render partial: 'ajax_best_copy_selection_error'
		else
			@cg = @physical_object.active_component_group
			if @cg.nil?
				@msg = "Physical Object #{params[:iu_barcode]} is not in active workflow. It currently should be #{@physical_object.current_workflow_status.type_and_location}"
				render partial: 'ajax_best_copy_selection_error'
			elsif !ComponentGroup::BEST_COPY_TYPES.include?(@cg.group_type)
				@msg = "Physical Object #{params[:iu_barcode]}'s current active component group is not Best Copy. It is: #{@physical_object.active_component_group.group_type}'"
				render partial: 'ajax_best_copy_selection_error'
			else
				render partial: 'ajax_best_copy_selection_component_group'
			end
		end
	end

	def best_copy_selection_update
		@component_group = ComponentGroup.find(params[:component_group][:id])
		po_ids = params[:pos].split(',').collect { |p| p.to_i }
		@pos = PhysicalObject.where(id: po_ids)
		@cg_pos = []
		@returned = []
		if @pos.size > 0
			ComponentGroup.transaction do
				@new_cg = ComponentGroup.new(title_id: @component_group.title_id, group_type: 'Reformatting (MDPI)', group_summary: '* Created from Best Copy Selection *')
				if params['4k']
					@new_cg.scan_resolution = '4k'
				else
					@new_cg.scan_resolution = '2k'
				end
				@new_cg.color_space = params[:component_group][:color_space]
				@new_cg.clean = params[:component_group][:clean]
				@new_cg.return_on_reel = params[:component_group][:return_on_reel]
				@new_cg.save!
			end
			if @new_cg.persisted?
				@pos.each do |p|
					@cg_pos << p
					ComponentGroupPhysicalObject.new(physical_object_id: p.id, component_group_id: @new_cg.id).save!
					p.active_component_group = @new_cg
					p.workflow_statuses << WorkflowStatus.build_workflow_status(
						(@component_group.group_type == ComponentGroup::BEST_COPY_MDPI_WELLS ? WorkflowStatus::WELLS_TO_ALF_CONTAINER : WorkflowStatus::TWO_K_FOUR_K_SHELVES),
						p)
					p.save!
				end
			end
		end
		@component_group.physical_objects.each do |p|
			if !po_ids.include?(p.id)
				@returned << p
				p.workflow_statuses << WorkflowStatus.build_workflow_status(p.storage_location, p)
				p.save!
			end
		end
		@physical_objects = []#PhysicalObject.where_current_workflow_status_is(nil, nil, WorkflowStatus::BEST_COPY_ALF)
		render 'best_copy_selection'
	end

	def issues_shelf
		@physical_objects = PhysicalObject.where_current_workflow_status_is(nil, nil, WorkflowStatus::ISSUES_SHELF)
	end

	def ajax_issues_shelf_barcode
		bc = params[:iu_barcode]
		@physical_object = PhysicalObject.where(iu_barcode: bc).first
		if @physical_object.nil?
			@msg = "Could not find Physical Object with IU barcode: #{bc}"
			# we can use ajax_best_copy_selection_error partial because it just renders the msg
			render partial: 'workflow/ajax_best_copy_selection_error'
		elsif @physical_object.current_workflow_status.status_name != WorkflowStatus::ISSUES_SHELF
			@msg = "Physical Object #{bc} is not currently on the Issues Shelf! It is #{@physical_object.current_workflow_status.status_name}"
			render partial: 'workflow/ajax_best_copy_selection_error'
		else
			@others = @physical_object.active_component_group.physical_objects.select{ |p| @physical_object != p }
			render partial: 'workflow/ajax_issues_shelf_barcode'
		end
	end

	def ajax_issues_shelf_update
		@physical_object = PhysicalObject.find(params[:id])
		status_name = params[:physical_object][:current_workflow_status]
		if WorkflowStatus::STATUSES_TO_NEXT_WORKFLOW[WorkflowStatus::ISSUES_SHELF].include?(status_name)
			if params[:physical_object][:updated] == '1'
				ws = WorkflowStatus.build_workflow_status(status_name, @physical_object)
				@physical_object.workflow_statuses << ws
				@physical_object.save
				flash.now[:notice] = "Physical Object #{@physical_object.iu_barcode} updated to #{@physical_object.current_workflow_status.status_name}"
			else
				flash.now[:warning] = "Please update the Physical Objects condition metadata before updating it's workflow location."
			end
		else
			flash.now[:warning] = "Physical Object not updated! Invalid workflow status location: '#{status_name}'"
		end
		@physical_objects = PhysicalObject.where_current_workflow_status_is(nil, nil, WorkflowStatus::ISSUES_SHELF)
		render 'issues_shelf'
	end

	def cancel_pulled
		@physical_object = PhysicalObject.find(params[:id])
		if @physical_object.active_component_group.physical_objects.size > 0

		else

		end
		render 'workflow/receive_from_storage'
	end
	def re_queue_pulled

	end
	def mark_pulled_missing

	end

	# main page for scanning a barcode to update it's workflow status location
	def update_location
	end
	# ajax call that handles the lookup of the barcode scanned into the above
	def ajax_update_location
		bc = params[:barcode]
		@physical_object = PhysicalObject.where("iu_barcode = #{bc} OR mdpi_barcode = #{bc}").first
		render partial: 'workflow/ajax_update_location'
	end
	#ajax call that handles the updating of the PO based on what was selected from the form submission of #ajax_update_location
	def ajax_update_location_post
		@physical_object = PhysicalObject.where(iu_barcode: params[:barcode]).first
		if @physical_object
			ws = WorkflowStatus.build_workflow_status(params[:location], @physical_object, true)
			@physical_object.workflow_statuses << ws
			@physical_object.save
			flash.now[:notice] = "#{@physical_object.iu_barcode} has been updated to #{@physical_object.current_workflow_status.status_name}"
		else
			flash.now[:warning] = "Could not find Physical Object with barcode #{params[:barcode]}"
		end
		render 'workflow/update_location'
	end

	def return_from_mold_abatement
		@physical_objects = PhysicalObject.where_current_workflow_status_is(nil, nil, WorkflowStatus::MOLD_ABATEMENT)
	end

	def ajax_mold_abatement_barcode
		@physical_object = PhysicalObject.where(iu_barcode: params[:bc].to_i).first
		render partial: 'workflow/ajax_mold_abatement_barcode'
	end

	def update_return_from_mold_abatement
		@physical_object = PhysicalObject.find(params[:id])
		s = WorkflowStatus.build_workflow_status(params[:physical_object][:current_workflow_status], @physical_object)
		@physical_object.workflow_statuses << s
		@physical_object.update_attributes(mold: params[:physical_object][:mold])
		flash[:notice] = "#{@physical_object.iu_barcode} was updated to #{@physical_object.current_workflow_status.status_name}, with Mold attribute set to: #{@physical_object.mold}"
		redirect_to :return_from_mold_abatement
	end

	def show_mark_found
		@physical_objects = PhysicalObject.where_current_workflow_status_is(nil, nil, WorkflowStatus::MISSING)
		render 'mark_found'
	end

	def update_mark_found
		@physical_object = PhysicalObject.joins(:workflow_statuses).where(iu_barcode: params[:iu_barcode]).first
		if @physical_object.nil?
			flash[:warning] = "Could not find Physical Object with IU barcode: #{params[:iu_barcode]}"
		elsif !po_missing?(@physical_object)
			flash[:warning] = "#{params[:iu_barcode]} is not currently marked missing. It should be at #{@physical_object.current_location}"
		elsif (@physical_object.active_component_group.nil? && !WorkflowStatus::PULLABLE_STORAGE.include?(@physical_object.previous_location) && @physical_object.previous_location != WorkflowStatus::JUST_INVENTORIED_WELLS && @physical_object.previous_location != WorkflowStatus::JUST_INVENTORIED_ALF)
			flash[:warning] = "Currently, only Physical Object with an active component group, or objects that went missing in storage can be marked found."
		else
			ws = WorkflowStatus.build_workflow_status(@physical_object.previous_location, @physical_object)
			@physical_object.workflow_statuses << ws
			@physical_object.save
			flash[:notice] = "#{@physical_object.iu_barcode} was updated to #{@physical_object.current_location}"
		end
		@physical_objects = PhysicalObject.where_current_workflow_status_is(nil, nil, WorkflowStatus::MISSING)
		render 'mark_found'
	end

	def ajax_mark_found
		bc = params[:iu_barcode]
		@physical_object = PhysicalObject.joins(:workflow_statuses).where(iu_barcode: bc).first
		if @physical_object.nil?
			@msg = "Could not find Physical Object with IU Barcode #{bc}"
		elsif !po_missing?(@physical_object)
			@msg = "#{bc} is not currently marked as missing. It should be at #{@physical_object.current_location}"
		elsif (@physical_object.active_component_group.nil? && !WorkflowStatus::PULLABLE_STORAGE.include?(@physical_object.previous_location) && @physical_object.previous_location != WorkflowStatus::JUST_INVENTORIED_WELLS && @physical_object.previous_location != WorkflowStatus::JUST_INVENTORIED_ALF)
			@msg = "#{bc} cannot currently be marked Found. It no longer has an active component group and was lost in active workflow. Use 'Return to Storage' instead"
		end
		render partial: 'ajax_return_to_storage'
	end

	def digitization_staging_list
		@physical_objects = PhysicalObject.where_current_workflow_status_is(nil, nil, WorkflowStatus::TWO_K_FOUR_K_SHELVES)
		respond_to do |format|
			format.csv {send_data pos_to_cvs(@physical_objects), filename: 'digitization_staging.csv' }
    end
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

	def po_missing?(po)
		po.current_location == WorkflowStatus::MISSING
	end


end
