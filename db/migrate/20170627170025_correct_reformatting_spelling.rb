class CorrectReformattingSpelling < ActiveRecord::Migration
  def change
    ControlledVocabulary.where(model_type: 'ComponentGroup', value: 'Reformating').update_all(value: 'Reformatting')
  end
end
