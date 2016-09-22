class AddSeriesTitleIdToTitle < ActiveRecord::Migration
  def change
    add_column :titles, :series_title_id, :integer, limit: 8
  end
end
