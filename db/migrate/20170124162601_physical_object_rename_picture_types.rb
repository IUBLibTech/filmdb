class PhysicalObjectRenamePictureTypes < ActiveRecord::Migration
  def up
    rename_column :physical_objects, :picture_picture_kinescope, :picture_kinescope
  end

  def down
    rename_column :physical_objects, :picture_kinescope, :picture_picture_kinescope
  end
end
