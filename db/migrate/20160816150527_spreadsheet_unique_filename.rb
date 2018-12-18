class SpreadsheetUniqueFilename < ActiveRecord::Migration
  def change
    add_index :spreadsheets, :filename, unique: true
  end

end
