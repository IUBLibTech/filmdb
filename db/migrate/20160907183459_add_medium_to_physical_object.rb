class AddMediumToPhysicalObject < ActiveRecord::Migration
  def change
    add_column :physical_objects, :medium, :string, nil: false
  end
end
