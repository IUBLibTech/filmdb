class PodPush < ActiveRecord::Base
	belongs_to :cage

	def result_as_hash
		if result
			JSON.parse result
		else
			{}
		end
	end
end
