class ImportSeriesPartFromSpreadsheets < ActiveRecord::Migration
  include SeriesPartFixHelper
  def up
    parse_files
  end
  def down
    #there is no down...
  end
end
