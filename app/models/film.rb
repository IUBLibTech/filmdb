class Film < ActiveRecord::Base
  acts_as :physical_object

  validates :gauge, presence: true
end
