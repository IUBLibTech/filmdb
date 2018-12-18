class IncreaseBarcodeLimits < ActiveRecord::Migration
  def change
    change_column :physical_objects, :iu_barcode, :integer, limit: 8
    change_column :physical_objects, :mdpi_barcode, :integer, limit: 8
    change_column :cage_shelves, :mdpi_barcode, :integer, limit: 8
  end
end
