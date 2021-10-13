class ChangeProductionDateToText < ActiveRecord::Migration
  def change
    change_column :equipment_technologies, :production_year, :text
  end
end
