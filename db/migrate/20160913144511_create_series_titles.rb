class CreateSeriesTitles < ActiveRecord::Migration
  def change
    create_table :series_titles do |t|
      t.string :series_title
      t.text :description
      t.timestamps
    end
  end
end
