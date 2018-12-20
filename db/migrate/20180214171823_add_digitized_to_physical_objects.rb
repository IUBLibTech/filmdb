class AddDigitizedToPhysicalObjects < ActiveRecord::Migration
  def change
    add_column :physical_objects, :digitized, :boolean
  end
end
