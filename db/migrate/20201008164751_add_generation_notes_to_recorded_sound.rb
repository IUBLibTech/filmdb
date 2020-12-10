class AddGenerationNotesToRecordedSound < ActiveRecord::Migration[5.0]
  def change
    add_column :recorded_sounds, :generation_notes, :text
  end
end
