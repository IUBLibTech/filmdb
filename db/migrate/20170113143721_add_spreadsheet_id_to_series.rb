class AddSpreadsheetIdToSeries < ActiveRecord::Migration
  def change
    add_column :series, :spreadsheet_id, :integer, limit: 8
  end
end
