class AddReadyToShipToCages < ActiveRecord::Migration
  def change
    add_column :cages, :ready_to_ship, :boolean, default: false
    add_column :cages, :shipped, :boolean, default: false
  end
end
