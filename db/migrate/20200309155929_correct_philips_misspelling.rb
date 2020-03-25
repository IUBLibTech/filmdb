class CorrectPhilipsMisspelling < ActiveRecord::Migration[5.0]
  def change
    ControlledVocabulary.transaction do
      ControlledVocabulary.where(model_type: 'Video', model_attribute: ':stock', value: 'Phillips').update(value: 'Philips')
      Video.where(stock: 'Phillips').update_all(stock: 'Philips')
    end
  end
end
