class AddSponsorToTitleCreators < ActiveRecord::Migration
  def change
    ControlledVocabulary.new(model_type: 'Title', model_attribute: ':title_creator_role_type', value: 'Sponsor').save!
  end
end
