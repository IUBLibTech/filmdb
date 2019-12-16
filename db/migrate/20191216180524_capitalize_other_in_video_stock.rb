class CapitalizeOtherInVideoStock < ActiveRecord::Migration[5.0]
  def change
    ControlledVocabulary.where(model_type: 'Video', model_attribute: ':stock', value: 'other').update_all(value: 'Other')
    Video.where(stock: 'other').update_all(stock: 'Other')
  end
end
