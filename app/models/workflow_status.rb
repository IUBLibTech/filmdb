class WorkflowStatus < ActiveRecord::Base
	belongs_to :physical_object
	belongs_to :workflow_status_template
	belongs_to :workflow_status_location

	def type_and_location
		"#{workflow_status_template.name}"+(workflow_status_location.nil? ? '' : " [#{workflow_status_location.to_s}]")
	end

	def status_type
		workflow_status_template.name
	end

end
