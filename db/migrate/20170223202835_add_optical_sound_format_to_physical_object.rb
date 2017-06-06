class AddOpticalSoundFormatToPhysicalObject < ActiveRecord::Migration
  def change
    add_column :physical_objects, :sound_format_optical, :boolean
  end
end
