class AddSpreadsheetIdToTitle < ActiveRecord::Migration
  def change
    add_column :titles, :spreadsheet_id, :integer, limit: 8
  end
end
