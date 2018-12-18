class RenameTitleDateTypeToDateType < ActiveRecord::Migration
  def up
    rename_column :title_dates, :type, :date_type
  end

  def down
    rename_column :title_dates, :date_type, :type
  end
end
