class DropCollectionInventoryConfigurationTable < ActiveRecord::Migration
  def change
    drop_table :collection_inventory_configurations if table_exists?(:collection_inventory_configurations)
  end
end
