class AddTitleControlToPhysicalObject < ActiveRecord::Migration
  def change
    add_column :physical_objects, :title_control_number, :string
    add_column :collection_inventory_configurations, :title_control_number, :boolean
  end
end
