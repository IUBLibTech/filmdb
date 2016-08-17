class SpreadsheetsAddProgressAndSuccess < ActiveRecord::Migration
  def change
    add_column :spreadsheets, :successful_upload, :boolean, default: false
  end
end
