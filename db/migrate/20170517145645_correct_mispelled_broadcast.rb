class CorrectMispelledBroadcast < ActiveRecord::Migration
  def change
    ControlledVocabulary.where(value: "Braodcast Engineer").update_all(value: "Broadcast Engineer")
  end
end
