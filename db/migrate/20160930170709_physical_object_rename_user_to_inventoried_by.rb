class PhysicalObjectRenameUserToInventoriedBy < ActiveRecord::Migration
  def change
    rename_column :physical_objects, :user_id, :inventoried_by
  end
end
