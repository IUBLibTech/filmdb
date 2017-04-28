# this controller is responsible for moving physical objects through the workflow. Each workflow state is comprised of
# a pair of of controller actions; one action to display all physical objects currently in that state, and a second action to
# provide ajax functionality to move individual physical objects on to the next workflow state
class WorkflowController < ApplicationController

	before_action :set_physical_object,
								only: [:ajax_mark_pull_requested, :ajax_mark_received_from_storage,
											 :ajax_mark_received_from_external, :ajax_mark_returned_to_storage, :ajax_mark_shipped_external]

	def pull_request
		@physical_objects = PhysicalObject.where_current_workflow_status_is(WorkflowStatusTemplate::PULL_REQUEST_QUEUED)
		@action_text = 'Mark Requested From Storage'
		@url = '/workflow/ajax/pull_requested/'
	end
	def ajax_mark_pull_requested
		@physical_object.workflow_statuses << WorkflowStatus.new(physical_object_id: @physical_object, workflow_status_template_id: WorkflowStatusTemplate::STATUS_TO_TEMPLATE_ID[WorkflowStatusTemplate::PULL_REQUEST_PROCESSED])
		@physical_object.save
		@physical_objects = PhysicalObject.where_current_workflow_status_is(WorkflowStatusTemplate::PULL_REQUEST_QUEUED)
		@action_text = 'Mark Requested From Storage'
		@url = '/workflow/ajax/pull_requested/'
		render partial: 'physical_objects_table'
	end

	def receive_from_storage
		@physical_objects = PhysicalObject.where_current_workflow_status_is(WorkflowStatusTemplate::PULL_REQUEST_PROCESSED)
		@action_text = 'Mark Received From Storage'
		@url = '/workflow/ajax/received_from_storage/'
	end
	def ajax_mark_received_from_storage
		@physical_object.workflow_statuses << WorkflowStatus.new(physical_object_id: @physical_object, workflow_status_template_id: WorkflowStatusTemplate::STATUS_TO_TEMPLATE_ID[WorkflowStatusTemplate::PULL_REQUEST_RECEIVED])
		@physical_object.save
		@physical_objects = PhysicalObject.where_current_workflow_status_is(WorkflowStatusTemplate::PULL_REQUEST_PROCESSED)
		@action_text = 'Mark Requested From Storage'
		@url = '/workflow/ajax/pull_requested/'
		render partial: 'physical_objects_table'
	end

	def ship_external
		@physical_objects = PhysicalObject.where_current_workflow_status_is(WorkflowStatusTemplate::PULL_REQUEST_RECEIVED)
		@action_text = 'Mark Shipped To External'
		@url = '/workflow/ajax/shipped_external/'
	end
	def ajax_mark_shipped_external
		@physical_object.workflow_statuses << WorkflowStatus.new(physical_object_id: @physical_object, workflow_status_template_id: WorkflowStatusTemplate::STATUS_TO_TEMPLATE_ID[WorkflowStatusTemplate::SHIPPED_TO_EXTERNAL])
		@physical_object.save
		@physical_objects = PhysicalObject.where_current_workflow_status_is(WorkflowStatusTemplate::PULL_REQUEST_RECEIVED)
		@action_text = 'Mark Shipped To External'
		@url = '/workflow/ajax/shipped_external/'
		render partial: 'physical_objects_table'
	end

	def receive_from_external
		@physical_objects = PhysicalObject.where_current_workflow_status_is(WorkflowStatusTemplate::SHIPPED_TO_EXTERNAL)
		@action_text = 'Returned From External'
		@url = '/workflow/ajax/received_external/'
	end
	def ajax_mark_received_from_external
		@physical_object.workflow_statuses << WorkflowStatus.new(physical_object_id: @physical_object, workflow_status_template_id: WorkflowStatusTemplate::STATUS_TO_TEMPLATE_ID[WorkflowStatusTemplate::RETURNED_FROM_EXTERNAL])
		@physical_object.save
		@physical_objects = PhysicalObject.where_current_workflow_status_is(WorkflowStatusTemplate::SHIPPED_TO_EXTERNAL)
		@action_text = 'Returned From External'
		@url = '/workflow/ajax/received_external/'
		render partial: 'physical_objects_table'
	end

	def return_to_storage
		@physical_objects = PhysicalObject.where_current_workflow_status_is(WorkflowStatusTemplate::RETURNED_FROM_EXTERNAL)
		@action_text = 'Mark Returned To Storage'
		@url = '/workflow/ajax/returned_to_storage/'
	end
	def ajax_mark_returned_to_storage
		@physical_object.workflow_statuses << WorkflowStatus.new(physical_object_id: @physical_object, workflow_status_template_id: WorkflowStatusTemplate::STATUS_TO_TEMPLATE_ID[WorkflowStatusTemplate::IN_STORAGE])
		@physical_object.save
		@physical_objects = PhysicalObject.where_current_workflow_status_is(WorkflowStatusTemplate::RETURNED_FROM_EXTERNAL)
		@action_text = 'Mark Returned To Storage'
		@url = '/workflow/ajax/returned_to_storage/'
		render partial: 'physical_objects_table'
	end

	private
	def set_physical_object
		@physical_object = PhysicalObject.find(params[:id])
	end

end
