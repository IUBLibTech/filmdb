class AddCaptionsOrSubtitlesNotesToPhysicalObject < ActiveRecord::Migration
  def change
    add_column :physical_objects, :captions_or_subtitles_notes, :text
  end
end
