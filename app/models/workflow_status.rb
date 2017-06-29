class WorkflowStatus < ActiveRecord::Base
	belongs_to :physical_object
	belongs_to :component_group

	WORKFLOW_TYPES = ['Storage', 'In Workflow', 'Shipped', 'Deaccessioned']

	MDPI = 'MDPI'
	IULMIA = 'IULMIA'

	# all status names
	IN_STORAGE_INGESTED = 'In Storage (Ingested)'
	IN_STORAGE_AWAITING_INGEST = 'In Storage (Awaiting Ingest)'
	IN_FREEZER = 'In Freezer'
	AWAITING_FREEZER = 'Awaiting Freezer'
	MOLD_ABATEMENT = 'Mold Abatement'
	MISSING = 'Missing'
	IN_CAGE = 'In Cage (ALF)'
	QUEUED_FOR_PULL_REQUEST = 'Queued for Pull Request'
	PULL_REQUESTED = 'Pull Requested'
	RECEIVED_FROM_STORAGE_STAGING = 'Received from Storage Staging (ALF)'
	TWO_K_FOUR_K_SHELVES = "2k/4k Shelves (ALF)"
	ISSUES_SHELF = 'Issues Shelf (ALF)'
	BEST_COPY = 'Best Copy (ALF)'
	IN_WORKFLOW_WELLS = 'In Workflow (Wells)'
	SHIPPED_EXTERNALLY = 'Shipped Externally'
	DEACCESSIONED = 'Deaccessioned'
	JUST_INVENTORIED_WELLS = 'Just Inventoried (Wells)'
	JUST_INVENTORIED_ALF = 'Just Inventoried (ALF)'

	STATUS_TYPES_TO_STATUSES = {
		# physical location is ALF
		'Storage' => [IN_STORAGE_INGESTED, IN_STORAGE_AWAITING_INGEST, IN_FREEZER, AWAITING_FREEZER, MOLD_ABATEMENT, MISSING ],
		#physical location is either ALF-IULMIA or Wells-IULMIA differentiated by WHICH_WORKFLOW values
		'In Workflow' => [QUEUED_FOR_PULL_REQUEST, PULL_REQUESTED, RECEIVED_FROM_STORAGE_STAGING, TWO_K_FOUR_K_SHELVES, ISSUES_SHELF, BEST_COPY, IN_CAGE, IN_WORKFLOW_WELLS, JUST_INVENTORIED_WELLS, JUST_INVENTORIED_ALF],
	  # physical location is the external_entity_id foreign key reference
		'Shipped' => [SHIPPED_EXTERNALLY],
		# physical location is the dumpster out back
	  'Deaccessioned' => [DEACCESSIONED]
	}

	PULLABLE_STORAGE = [IN_STORAGE_INGESTED, IN_STORAGE_AWAITING_INGEST, IN_FREEZER, AWAITING_FREEZER]
	SPREADSHEET_START_LOCATIONS = [IN_STORAGE_AWAITING_INGEST, IN_STORAGE_INGESTED, IN_FREEZER, AWAITING_FREEZER, JUST_INVENTORIED_ALF, JUST_INVENTORIED_WELLS, MOLD_ABATEMENT]

	STATUSES_TO_NEXT_WORKFLOW = {
		IN_STORAGE_INGESTED => [QUEUED_FOR_PULL_REQUEST],
		IN_STORAGE_AWAITING_INGEST => [QUEUED_FOR_PULL_REQUEST, IN_STORAGE_INGESTED],
		IN_FREEZER => [QUEUED_FOR_PULL_REQUEST],
		AWAITING_FREEZER => [QUEUED_FOR_PULL_REQUEST, IN_FREEZER],
		MOLD_ABATEMENT => [RECEIVED_FROM_STORAGE_STAGING, IN_STORAGE_INGESTED, IN_STORAGE_AWAITING_INGEST, IN_FREEZER, AWAITING_FREEZER, DEACCESSIONED],
		MISSING => [IN_STORAGE_INGESTED, IN_STORAGE_AWAITING_INGEST, IN_FREEZER, AWAITING_FREEZER, DEACCESSIONED],
		IN_CAGE => [SHIPPED_EXTERNALLY, TWO_K_FOUR_K_SHELVES],
		QUEUED_FOR_PULL_REQUEST => ([PULL_REQUESTED] + PULLABLE_STORAGE),
		PULL_REQUESTED => (PULLABLE_STORAGE + [IN_WORKFLOW_WELLS, BEST_COPY, ISSUES_SHELF, TWO_K_FOUR_K_SHELVES, DEACCESSIONED, MOLD_ABATEMENT]),
		RECEIVED_FROM_STORAGE_STAGING => [TWO_K_FOUR_K_SHELVES],
		TWO_K_FOUR_K_SHELVES => [IN_CAGE],
		ISSUES_SHELF => ((PULLABLE_STORAGE + [MOLD_ABATEMENT]) + [RECEIVED_FROM_STORAGE_STAGING, DEACCESSIONED]),
		BEST_COPY => (PULLABLE_STORAGE + [MOLD_ABATEMENT] + [RECEIVED_FROM_STORAGE_STAGING, DEACCESSIONED]),
		IN_WORKFLOW_WELLS => ((PULLABLE_STORAGE + [MOLD_ABATEMENT]) + [SHIPPED_EXTERNALLY, DEACCESSIONED]),
		SHIPPED_EXTERNALLY => (PULLABLE_STORAGE + [IN_WORKFLOW_WELLS]),
		DEACCESSIONED => [],
		JUST_INVENTORIED_WELLS => [IN_STORAGE_AWAITING_INGEST, IN_STORAGE_INGESTED, AWAITING_FREEZER, IN_WORKFLOW_WELLS],
		JUST_INVENTORIED_ALF => [IN_STORAGE_AWAITING_INGEST, IN_STORAGE_INGESTED, IN_FREEZER, AWAITING_FREEZER, MOLD_ABATEMENT, RECEIVED_FROM_STORAGE_STAGING, BEST_COPY]
	}

	# Constructs the next status that a physical object will be moving to based on status_name. Will (eventually) validate whether the previous_workflow_status
	# permits movement into status_name
	def self.build_workflow_status(status_name, physical_object)
		current = physical_object.current_workflow_status
		if ((current.nil? && !SPREADSHEET_START_LOCATIONS.include?(status_name)) ||	(!current.nil? && !current.valid_next_workflow?(status_name)))
			raise RuntimeError, "#{physical_object.current_workflow_status.type_and_location} cannot be moved into workflow status #{status_name}"
		end
		if status_name == JUST_INVENTORIED_WELLS
			ws = WorkflowStatus.new(
				physical_object_id: physical_object.id,
				workflow_type: which_workflow_type(status_name),
				whose_workflow: IULMIA,
				status_name: status_name,
				component_group_id: nil)
		else
			ws = WorkflowStatus.new(
				physical_object_id: physical_object.id,
				workflow_type: which_workflow_type(status_name),
				whose_workflow: find_workflow(status_name, physical_object),
				status_name: status_name,
				component_group_id: ((STATUS_TYPES_TO_STATUSES['Storage'] << DEACCESSIONED).include? status_name ? nil? : physical_object.current_workflow_status.component_group_id))
			if !physical_object.current_workflow_status.external_entity_id.nil?
				ws.external_entity_id = previous_workflow_status.external_entity_id
			end
		end
		ws
	end

	def valid_next_workflow?(next_workflow)
		STATUSES_TO_NEXT_WORKFLOW[self.status_name].include? next_workflow
	end

	def self.mdpi_receive_options(storage_string)
		# when a physical object is returned to storage it should determine storage_string based on its location (storage ingested, storage awaiting ingest, freezer, awaiting freezer)
		[BEST_COPY, TWO_K_FOUR_K_SHELVES, ISSUES_SHELF, storage_string].each.collect { |s| [s, s] }
	end

	def self.workflow_type_from_status(status_name)
		STATUS_TYPES_TO_STATUSES.each do |key|
			if STATUS_TYPES_TO_STATUSES[key].include? status_name
				return key
			end
		end
		nil
	end

	def self.is_storage_status?(status)
		s = workflow_type_from_status(status)
		s != nil && s == 'Storage'
	end

	def can_be_pulled?
		STATUS_TYPES_TO_STATUSES['Storage'].include?(status_name) && status_name != MISSING && status_name != MOLD_ABATEMENT
	end

	def type_and_location
		"#{status_name}#{whose_workflow.blank? ? '' : " (#{whose_workflow})"}"
	end

	def ==(other)
		self.class == other.class && self.status_name == other.status_name && self.whose_workflow == other.whose_workflow
	end

	private
	def self.find_workflow(status_name, po)
		if po.active_component_group.nil?
			#clear the MDPI IULMIA workflow when it is no longer in their workflow
			if [IN_STORAGE_INGESTED, IN_STORAGE_AWAITING_INGEST, IN_FREEZER, AWAITING_FREEZER, MISSING, MOLD_ABATEMENT, JUST_INVENTORIED_WELLS].include? status_name
				''
			else
				raise WorkflowError 'Missing active component group!!!'
			end
		else
			po.active_component_group.whose_workflow
		end
	end

	def self.which_workflow_type(status_name)
		STATUS_TYPES_TO_STATUSES.keys.each do |k|
			if STATUS_TYPES_TO_STATUSES[k].include? status_name
				return k
			end
		end
		return ''
	end

end
