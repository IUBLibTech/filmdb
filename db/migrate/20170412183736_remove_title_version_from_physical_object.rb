class RemoveTitleVersionFromPhysicalObject < ActiveRecord::Migration
  def up
    remove_column :physical_objects, :title_version
  end

  def down
    add_column :physical_objects, :title_version, :string
  end
end
