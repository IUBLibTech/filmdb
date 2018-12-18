class AddMultipleItemsInCanToPhysicalObject < ActiveRecord::Migration
  def change
    add_column :physical_objects, :multiple_items_in_can, :boolean
  end
end
