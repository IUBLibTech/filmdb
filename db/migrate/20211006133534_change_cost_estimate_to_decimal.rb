class ChangeCostEstimateToDecimal < ActiveRecord::Migration
  def up
    EquipmentTechnology.all.update_all(cost_estimate: nil)
    change_column :equipment_technologies, :cost_estimate, :decimal, precision: 10, scale: 2
  end

  def down
    remove_column :equipment_technologies, :cost_estimate
    add_column :equipment_technologies, :cost_estimate, :text
  end
end
