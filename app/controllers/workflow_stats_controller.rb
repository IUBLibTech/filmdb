class WorkflowStatsController < ApplicationController
	include PhysicalObjectsHelper

	def digitization_staging_stats
		NS = 'Not Specified'
		@physical_objects = PhysicalObject.where_current_workflow_status_is(WorkflowStatus::TWO_K_FOUR_K_SHELVES)
		@gauges = {}
		@can_sizes = {NS: 0}
		@scan_resolutions = {}
		@physical_objects.each do |p|
			if @gauges[p.gauge].nil?
				@gauges[p.gauge] = 0
			end

			@gauges[p.gauge] += 1
			if p.can_size.blank?
				@can_sizes[NS] += 1
			else
				if @can_sizes[p.can_size].nil?
					@can_sizes[p.can_size] = 0
				end
				@can_sizes[p.can_size] += 1
			end

			cg = p.active_component_group
			if @scan_resolutions[cg.scan_resolution].nil?
				@scan_resolutions[cg.scan_resolution] = 0
			end
			@scan_resolutions[cg.scan_resolution] += 1

		end
		render partial: 'digitization_staging_stats'
	end

end
