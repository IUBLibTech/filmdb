class Unit < ActiveRecord::Base
	has_many :physical_objects
	has_many :collections
end
