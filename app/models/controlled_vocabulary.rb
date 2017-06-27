class ControlledVocabulary < ActiveRecord::Base
  scope :physical_object_cv, -> {
    cv = ControlledVocabulary.where(model_type: 'PhysicalObject').select(:model_attribute, :value).order(:model_attribute, :menu_index)
    cv_map(cv)
  }

  scope :title_cv, -> {
    cv = ControlledVocabulary.where(model_type: 'Title').select(:model_attribute, :value).order(:model_attribute, :menu_index)
    cv_map(cv)
  }

  scope :title_date_cv, -> {
    cv = ControlledVocabulary.where(model_type: 'TitleDate').select(:model_attribute, :value).order(:model_attribute, :menu_index)
    cv_map(cv)
  }

  scope :title_genre_cv, -> {
    cv = ControlledVocabulary.where(model_type: 'TitleGenre').select(:model_attribute, :value).order(:model_attribute, :menu_index)
    cv_map(cv)
  }

  scope :title_form_cv, -> {
    cv = ControlledVocabulary.where(model_type: 'TitleForm').select(:model_attribute, :value).order(:model_attribute, :menu_index)
    cv_map(cv)
  }

  scope :language_cv, -> {
    cv = ControlledVocabulary.where(model_type: 'Language').select(:model_attribute, :value).order(:model_attribute, :menu_index)
    cv_map(cv)
  }

  scope :component_group_cv, -> {
    cv = ControlledVocabulary.where(model_type: 'ComponentGroup').select(:model_attribute, :value).order(:value, :menu_index)
    cv_map(cv)
  }

  scope :physical_object_date_cv, -> {
    cv = ControlledVocabulary.where(model_type: 'PhysicalObjectDate').select(:id, :model_attribute, :value).order(:menu_index)
    map = {}
    # map for these is slightly different as it should bind to the controlled vocabulary ID not copy the text :value
    cv.each do |v|
      id = v.id
      value = v.value
      sym = v.model_attribute.tr(':','').to_sym
      map[sym] = [] if map[sym].nil?
      map[sym].push [value, id]
    end
    map
  }
  private
  def self.cv_map(scope_result)
    map = {}
    scope_result.each do |v|
      sym = v.model_attribute.tr(':', '').to_sym
      val = v.value
      map[sym] = [] if map[sym].nil?
      map[sym].push [val, val]
    end
    map
  end
end
