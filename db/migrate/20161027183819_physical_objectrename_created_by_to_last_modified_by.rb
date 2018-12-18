class PhysicalObjectrenameCreatedByToLastModifiedBy < ActiveRecord::Migration
  def up
    rename_column :physical_objects, :created_by, :modified_by
  end
  def down
    rename_column :physical_objects, :modified_by, :created_by
  end
end
