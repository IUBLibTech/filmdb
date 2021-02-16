class AddGenerationNotesToRecordedSound < ActiveRecord::Migration
  def change
    add_column :recorded_sounds, :generation_notes, :text
  end
end
