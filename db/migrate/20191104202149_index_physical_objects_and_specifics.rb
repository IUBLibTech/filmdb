class IndexPhysicalObjectsAndSpecifics < ActiveRecord::Migration
  def change
    add_index :physical_objects, [:actable_id, :actable_type], unique: true
  end
end
