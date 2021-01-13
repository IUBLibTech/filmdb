class RemovePhysicalObjectOldBarcodeIuBarcodeIndex < ActiveRecord::Migration
  def change
    remove_index :physical_object_old_barcodes, :iu_barcode
  end
end
