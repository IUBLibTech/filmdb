class AddAlfShelfToPhysicalObject < ActiveRecord::Migration
  def change
    add_column :physical_objects, :alf_shelf, :string, default: nil
  end
end
