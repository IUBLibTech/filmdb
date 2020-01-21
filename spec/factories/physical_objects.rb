FactoryGirl.define do
	factory :physical_object do
		iu_barcode { BarcodeHelper.valid_mdpi_barcode }
		inventoried_by { User.first.id }
		modified_by { User.first.id }
		unit_id { Unit.first.id }
		media_type 'Moving Image'
		medium 'film'
		created_at { Time.now }
		updated_at { Time.now }
	end

end