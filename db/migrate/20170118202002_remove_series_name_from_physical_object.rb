class RemoveSeriesNameFromPhysicalObject < ActiveRecord::Migration
  def up
    remove_column :physical_objects, :series_name
    remove_column :collection_inventory_configurations, :series_name
  end

  def down
    add_column :physical_objects, :series_name, :string
    add_column :collection_inventory_configurations, :series_name, :boolean
  end
end
