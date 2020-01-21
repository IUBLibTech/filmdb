class DropCollectionInventoryConfiguration < ActiveRecord::Migration
  def change
    drop_table :collection_inventory_configurations
  end
end
