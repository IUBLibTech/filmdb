class WorkflowStatusTemplate < ActiveRecord::Base

	# statuses:
	PULL_REQUEST_QUEUED = 'Pull Request Queued'
	PULL_REQUEST_PROCESSED = 'Pull Request Processed'
	PULL_REQUEST_RECEIVED = 'Pull Request Received'
	SHIPPED_TO_EXTERNAL = 'Shipped to Instition'
	RETURNED_FROM_EXTERNAL = 'Returned From Institution'
	IN_STORAGE = 'In Storage'

	STATES = [PULL_REQUEST_QUEUED, PULL_REQUEST_PROCESSED, PULL_REQUEST_RECEIVED, SHIPPED_TO_EXTERNAL, RETURNED_FROM_EXTERNAL, IN_STORAGE]
	STATUS_TO_TEMPLATE_ID = {}
	STATES.each do |s|
		t = WorkflowStatusTemplate.where(name: s).first
		unless t.nil?
			STATUS_TO_TEMPLATE_ID[s] = t.id
		end
	end

end
