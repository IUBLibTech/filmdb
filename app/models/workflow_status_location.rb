class WorkflowStatusLocation < ActiveRecord::Base
	#LOCATION_TYPES = [:storage, :on_site, :external, :extenal_memnon]
	#STORAGE_LOCATIONS = [ 'ALF' ]

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

	def self.digi_prep_location
		WorkflowStatusLocation.where(physical_location: '2k/4k Shelves').first
	end
	def self.digi_prep_location_id
		digi_prep_location.id
	end

	def self.freezer_location
		WorkflowStatusLocation.where(physical_location: 'In Freezer').first
	end
	def self.freezer_location_id
		freezer_location.id
	end

	def self.in_cage_location
		WorkflowStatusLocation.where(physical_location: 'Packed in Cage').first
	end
	def self.in_cage_location_id
		in_cage_location.id
	end

	def self.packed_location
		WorkflowStatusLocation.where(physical_location: 'Packed for Shipping').first
	end
	def self.packed_location_id
		packed_location.id
	end

	def self.memnon_location
		WorkflowStatusLocation.where(facility: 'Memnon').first
	end
	def self.memnon_location_id
		memnon_location.id
	end

	def self.missing_location
		WorkflowStatusLocation.where(physical_location: 'Missing').first
	end
	def self.missing_location_id

	end

	def to_s
		"#{facility}#{physical_location.blank? ? '' : " - #{physical_location}"}"
	end

end
