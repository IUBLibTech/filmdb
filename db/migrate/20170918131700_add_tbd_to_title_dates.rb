class AddTbdToTitleDates < ActiveRecord::Migration
  def change
    ControlledVocabulary.new(model_type: 'TitleDate', model_attribute: ':date_type', value: 'TBD').save!
  end
end
