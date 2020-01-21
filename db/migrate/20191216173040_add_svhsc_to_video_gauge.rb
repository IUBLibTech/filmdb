class AddSvhscToVideoGauge < ActiveRecord::Migration[5.0]
  def change
    ControlledVocabulary.new(model_type: 'Video', model_attribute: ':gauge', value: 'SVHS-C', active_status: true).save!
  end
end
