class PhysicalObjectDate < ActiveRecord::Base
	belongs_to :physical_object
	belongs_to :controlled_vocabulary

	def type
		self.controlled_vocabulary.value
	end

end
