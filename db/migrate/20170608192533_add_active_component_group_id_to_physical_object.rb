class AddActiveComponentGroupIdToPhysicalObject < ActiveRecord::Migration
  def change
    add_column :physical_objects, :component_group_id, :integer, limit: 8
  end
end
