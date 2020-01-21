class CreateVideos < ActiveRecord::Migration
  def up
    unless table_exists?('videos')
      create_table :videos do |t|
        t.string :gauge
        t.timestamps null: false
      end
    end
  end

  def down
    drop_table 'videos'
  end
end
