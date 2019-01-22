class AddMorePhysicalObjectCv < ActiveRecord::Migration
  def change
    fields = %w(Narration Spoken\ Language Main\ Titles TBD Other)
    fields.each do |f|
      ControlledVocabulary.new(model_type: "Language", model_attribute: ":language_type", value: f).save!
    end
  end
end
