class AddDetailedStockInfoToVideo < ActiveRecord::Migration[5.0]
  def change
    add_column :videos, :detailed_stock_information, :text
  end
end
