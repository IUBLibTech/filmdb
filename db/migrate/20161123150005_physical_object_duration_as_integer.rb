class PhysicalObjectDurationAsInteger < ActiveRecord::Migration
  def up
    change_column :physical_objects, :duration, :integer
  end

  def down
    change_column :physical_objects, :duration, :string
  end

end
