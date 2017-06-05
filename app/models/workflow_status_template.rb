class WorkflowStatusTemplate < ActiveRecord::Base

	# statuses - These values must match (case sensitive) all entries in the workflow_status_templates.name column
	IN_STORAGE = 'In Storage'
	PULL_REQUEST_QUEUED = 'Queued for Pull Request'
	PULL_REQUESTED = 'Pull Requested'
	ON_SITE = 'On Site'
	SHIPPED_TO_EXTERNAL = 'Shipped External'
	MISSING = 'Missing'

	STATES = [IN_STORAGE, PULL_REQUEST_QUEUED, PULL_REQUESTED, ON_SITE, SHIPPED_TO_EXTERNAL, MISSING]
	STATUS_TO_TEMPLATE_ID = {}
	STATES.each do |s|
		t = WorkflowStatusTemplate.where(name: s).first
		unless t.nil?
			STATUS_TO_TEMPLATE_ID[s] = t.id
		end
	end

end
