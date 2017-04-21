class RenameSoundTrackToSoundtrack < ActiveRecord::Migration
  def up
    ControlledVocabulary.where(value: 'Sound Track Damage').first.update_attributes(value: 'Soundtrack Damage')
  end

  def down
    ControlledVocabulary.where(value: 'Soundtrack Damage').first.update_attributes(value: 'Sound Track Damage')
  end
end
