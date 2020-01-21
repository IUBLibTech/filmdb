class IndexPhysicalObjectsAndSpecifics < ActiveRecord::Migration[5.0]
  def change
    add_index :physical_objects, [:actable_id, :actable_type], unique: true
  end
end
