class AddTwoChineseLanguages < ActiveRecord::Migration
  def change
	  ControlledVocabulary.new(model_type: 'Language', model_attribute: ':language', value: 'Chinese, Mandarin').save
	  ControlledVocabulary.new(model_type: 'Language', model_attribute: ':language', value: 'Chinese, Cantonese').save
  end
end
