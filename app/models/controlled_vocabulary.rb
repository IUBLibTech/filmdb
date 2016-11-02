class ControlledVocabulary < ActiveRecord::Base
  scope :physical_object_cv, -> {
    cv = ControlledVocabulary.where(model_type: 'PhysicalObject').select(:model_attribute, :value).order(:model_attribute, :index)
    cv_map = {}
    cv.each do |v|
      sym = v.model_attribute.tr(':', '').to_sym
      val = v.value
      cv_map[sym] = [] if cv_map[sym].nil?
      cv_map[sym].push [val, val]
    end
    cv_map
  }
end
