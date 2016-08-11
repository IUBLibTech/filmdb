class PhysicalObjectBelongsToSpreadsheet < ActiveRecord::Migration
  def change
    add_column :physical_objects, :spreadsheet_id, :integer, null: false
  end
end
