class AddTurkishToControlledVocab < ActiveRecord::Migration
  def change
    ControlledVocabulary.new(model_type: 'Language', model_attribute: ':language', value: 'Turkish').save
  end
end
