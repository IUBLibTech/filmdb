class ChangePhysicalObjectSilentBooleanToText < ActiveRecord::Migration
  def up
    rename_column :physical_objects, :silent, :sound
    change_column :physical_objects, :sound, :text
  end

  def down
    change_column :physical_objects, :sound, :boolean
    rename_column :physical_objects, :sound, :silent
  end
end
