class AddWellsCgTypes < ActiveRecord::Migration
  NEW_VALS = ['Cataloging', 'Digitization', 'Evaluation', 'Exhibition', 'Researcher', 'Teaching']
  def up
    ControlledVocabulary.where(model_type: 'ComponentGroup', active_status: false).delete_all
    NEW_VALS.each_with_index do |val, i|
      ControlledVocabulary.new(model_type: 'ComponentGroup', model_attribute: ':group_type', value: val, active_status: true, menu_index: i + 3).save
    end
  end

  def down
    ControlledVocabulary.where(model_type: 'ComponentGroup', value: NEW_VALS).delete_all
  end
end
