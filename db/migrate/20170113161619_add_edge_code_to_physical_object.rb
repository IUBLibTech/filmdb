class AddEdgeCodeToPhysicalObject < ActiveRecord::Migration
  def change
    add_column :physical_objects, :edge_code, :text
  end
end
