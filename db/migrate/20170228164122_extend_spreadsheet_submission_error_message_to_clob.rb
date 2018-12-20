class ExtendSpreadsheetSubmissionErrorMessageToClob < ActiveRecord::Migration
  def up
    change_column :spreadsheet_submissions, :failure_message, :text, limit: 4294967295
  end

  def down
    change_column :spreadsheet_submissions, :failure_message, :text, limit: 65535
  end
end
