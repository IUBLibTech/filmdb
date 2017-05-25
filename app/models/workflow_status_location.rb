class WorkflowStatusLocation < ActiveRecord::Base
	LOCATION_TYPES = [:storage, :on_site, :external, :extenal_memnon]
	STORAGE_LOCATIONS = [ 'ALF' ]

	def self.just_inventoried_location
		WorkflowStatusLocation.where(physical_location: 'Just Inventoried').first
	end
	def self.just_inventoried_location_id
		just_inventoried_location.id
	end

	def self.mold_abatement_location
		WorkflowStatusLocation.where(physical_location: 'Sent for Mold Abatement').first
	end
	def self.mold_abatement_location_id
		mold_abatement_location.id
	end

	def to_s
		"#{facility}#{physical_location.blank? ? '' : " - #{physical_location}"}"
	end

end
