class Digiprov < ActiveRecord::Base
  belongs_to :physical_object
  belongs_to :cage_shelf
end
