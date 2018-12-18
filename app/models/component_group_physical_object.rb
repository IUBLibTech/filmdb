class ComponentGroupPhysicalObject < ActiveRecord::Base
  belongs_to :component_group
  belongs_to :physical_object
end
