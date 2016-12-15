class CreateTitleGenres < ActiveRecord::Migration
  def change
    create_table :title_genres do |t|
      t.integer :title_id, limit: 8
      t.string :genre
      t.timestamps
    end
  end
end
