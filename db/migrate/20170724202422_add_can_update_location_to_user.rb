class AddCanUpdateLocationToUser < ActiveRecord::Migration
  def change
    add_column :users, :can_update_physical_object_location, :boolean, default: false
  end
end
