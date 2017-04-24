class WorkflowStatus < ActiveRecord::Base
	belongs_to :physical_object
	belongs_to :workflow_status_template

	def name
		workflow_status_template.name
	end
end
