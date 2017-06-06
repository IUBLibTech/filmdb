class AddGenerationMasterToPhysicalObject < ActiveRecord::Migration
  def change
    add_column :physical_objects, :generation_master, :boolean, null: true
  end
end
