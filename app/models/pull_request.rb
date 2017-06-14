class PullRequest < ActiveRecord::Base
	has_many :physical_object_pull_requests
	has_many :physical_objects, through: :physical_object_pull_requests
end
