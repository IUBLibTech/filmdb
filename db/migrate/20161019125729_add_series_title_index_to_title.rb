class AddSeriesTitleIndexToTitle < ActiveRecord::Migration
  def change
    add_column :titles, :series_title_index, :integer, null: true
  end
end
