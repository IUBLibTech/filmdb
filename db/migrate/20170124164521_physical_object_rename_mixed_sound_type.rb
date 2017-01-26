class PhysicalObjectRenameMixedSoundType < ActiveRecord::Migration
  def up
    rename_column :physical_objects, :sound_format_type_mixed, :sound_format_mixed
  end

  def down
    rename_column :physical_objects, :sound_format_mixed, :sound_format_type_mixed
  end
end
