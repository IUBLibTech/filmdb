class PullRequestsController < ApplicationController

	def index
		@pull_requests = PullRequest.all
	end

	def show
		@pull_request = PullRequest.find(params[:id])
	end

end
