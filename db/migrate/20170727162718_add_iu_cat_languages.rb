class AddIuCatLanguages < ActiveRecord::Migration
  def change
    ControlledVocabulary.reset_column_information
    ['Sudanese', 'Greek, modern', 'Dutch', 'Indonesian', 'Welsh', 'Latin'].each do |l|
      ControlledVocabulary.new(model_type: 'Language', model_attribute: ':language', value: l).save
    end
  end
end
