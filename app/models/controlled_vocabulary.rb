class ControlledVocabulary < ActiveRecord::Base
  scope :physical_object_cv, -> {
    cv = ControlledVocabulary.where(model_type: 'PhysicalObject').select(:model_attribute, :value).order(:model_attribute, :index)
    cv_map(cv)
  }

  scope :title_cv, -> {
    cv = ControlledVocabulary.where(model_type: 'Title').select(:model_attribute, :value).order(:model_attribute, :index)
    cv_map(cv)
  }

  scope :title_date_cv, -> {
    cv = ControlledVocabulary.where(model_type: 'TitleDate').select(:model_attribute, :value).order(:model_attribute, :index)
    cv_map(cv)
  }

  scope :title_genre_cv, -> {
    cv = ControlledVocabulary.where(model_type: 'TitleGenre').select(:model_attribute, :value).order(:model_attribute, :index)
    cv_map(cv)
  }

  scope :title_form_cv, -> {
    cv = ControlledVocabulary.where(model_type: 'TitleForm').select(:model_attribute, :value).order(:model_attribute, :index)
    cv_map(cv)
  }

  scope :language_cv, -> {
    cv = ControlledVocabulary.where(model_type: 'Language').select(:model_attribute, :value).order(:model_attribute, :index)
    cv_map(cv)
  }

  scope :component_group_cv, -> {
    cv = ControlledVocabulary.where(model_type: 'ComponentGroup').select(:model_attribute, :value).order(:model_attribute, :index)
    cv_map(cv)
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
