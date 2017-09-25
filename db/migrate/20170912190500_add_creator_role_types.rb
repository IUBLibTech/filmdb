class AddCreatorRoleTypes < ActiveRecord::Migration
  def change
    ["Animator", "Consultant", "Advisor", "Collaborator", "Scenario", "Production Supervisor"].each do |t|
      ControlledVocabulary.new(model_type: 'Title', model_attribute: ':title_creator_role_type', value: t).save!
    end
  end
end
