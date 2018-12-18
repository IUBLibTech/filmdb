class AddUsersToSpreadsheets < ActiveRecord::Migration
  def change
    add_column :users, :created_in_spreadsheet, :integer, limit: 8
  end
end
