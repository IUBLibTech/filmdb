class CorrectDirectionOfPhotographySpelling < ActiveRecord::Migration
  def change
    ControlledVocabulary.where(model_attribute: ':title_creator_role_type', value: 'Direction of Photography').update_all(value: 'Director of Photography')
  end
end
