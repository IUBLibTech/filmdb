class AddBlackAndWhiteVersionToPhysicalObject < ActiveRecord::Migration
  def change
    add_column :physical_objects, :black_and_white, :boolean
  end
end
