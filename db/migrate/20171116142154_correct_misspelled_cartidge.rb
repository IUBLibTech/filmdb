class CorrectMisspelledCartidge < ActiveRecord::Migration
  def change
    ControlledVocabulary.where(model_attribute: ':can_size', value: 'Cartidge').update_all(value: 'Cartridge')
    PhysicalObject.where(can_size: 'Cartidge').update_all(can_size: '')
  end
end
