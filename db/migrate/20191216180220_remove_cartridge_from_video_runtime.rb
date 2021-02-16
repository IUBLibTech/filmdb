class RemoveCartridgeFromVideoRuntime < ActiveRecord::Migration
  def change
    ControlledVocabulary.where(model_type: 'Video', model_attribute: ':maximum_runtime', value: 'cartridge').delete_all
    Video.where(maximum_runtime: 'cartridge').update_all(maximum_runtime: '')
  end
end
