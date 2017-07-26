class PullRequest < ActiveRecord::Base
	has_many :physical_object_pull_requests
	has_many :physical_objects, through: :physical_object_pull_requests
	belongs_to :requester, class_name: 'User', foreign_key: "requested_by", autosave: true
end
