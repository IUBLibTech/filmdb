class CorrectUknownMisspelling < ActiveRecord::Migration
  def change
    ControlledVocabulary.where(value: 'Uknown').update_all(value: 'Unknown')
  end
end
