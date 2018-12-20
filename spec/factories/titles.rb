FactoryGirl.define do
	factory :title do
		summary { "Some Summary Text" }
		notes { "Some Series Notes" }
		created_at { Time.now }
		updated_at { Time.now }
	end

end