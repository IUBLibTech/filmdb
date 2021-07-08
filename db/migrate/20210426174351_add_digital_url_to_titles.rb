class AddDigitalUrlToTitles < ActiveRecord::Migration
  def change
    add_column :titles, :stream_url, :string
  end
end
