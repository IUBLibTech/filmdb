class CreateSeries < ActiveRecord::Migration
  def change
    create_table :series do |t|
      t.timestamps
    end
    # add in the has_one series_title
    add_column :series_titles, :series_id, :integer, limit: 8
  end
end
