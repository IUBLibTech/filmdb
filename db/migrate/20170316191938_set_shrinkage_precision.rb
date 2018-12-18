class SetShrinkagePrecision < ActiveRecord::Migration
  def up
    change_column :physical_objects, :shrinkage, :decimal, precision: 4, scale: 3
  end
end
