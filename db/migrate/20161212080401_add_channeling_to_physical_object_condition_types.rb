class AddChannelingToPhysicalObjectConditionTypes < ActiveRecord::Migration
  def change
    add_column :physical_objects, :channeling, :string
  end
end
