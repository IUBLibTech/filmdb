class PhysicalObjectBelongsToCollectionAndUnit < ActiveRecord::Migration
  def change
    add_column :physical_objects, :unit_id, :integer, limit: 8
  end
end
