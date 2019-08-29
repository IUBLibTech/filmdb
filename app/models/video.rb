class Video < ActiveRecord::Base
  acts_as :physical_object

  validates :gauge, presence: true
  GAUGE_VALUES = ControlledVocabulary.where(model_type: 'Video', model_attribute: ':gauge').pluck(:value)

end
