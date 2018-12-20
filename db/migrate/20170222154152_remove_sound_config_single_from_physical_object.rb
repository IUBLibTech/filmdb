class RemoveSoundConfigSingleFromPhysicalObject < ActiveRecord::Migration
  def up
    remove_column :physical_objects, :sound_configuration_single
  end

  def down
    add_column :physical_objects, :sound_onfiguration_single, :boolean
  end
end
