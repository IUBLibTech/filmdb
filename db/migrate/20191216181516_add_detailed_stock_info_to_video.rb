class AddDetailedStockInfoToVideo < ActiveRecord::Migration
  def change
    add_column :videos, :detailed_stock_information, :text
  end
end
