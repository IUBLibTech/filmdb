class AddYearToTitleDates < ActiveRecord::Migration
  def change
    add_column :title_dates, :year, :integer
  end
end
