class WorkflowStatusLocationsController < ApplicationController

	before_action :set_workflow_status_location, only: [:show, :edit]

	def index
		@workflow_status_locations = WorkflowStatusLocation.all.order(:location_type, :facility, :physical_location)
	end

	def new
		@workflow_status_location = WorkflowStatusLocation.new
	end

	def create

	end

	def edit

	end

	def update

	end

	private
	def set_workflow_status_location
		WorkflowStatusLocation.find(params[:id])
	end

	def workflow_status_location_params
		params.require(:workflow_status_location).permit(:type, :facility, :physical_location, :notes)
	end
end
