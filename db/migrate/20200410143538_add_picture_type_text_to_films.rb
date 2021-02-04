class AddPictureTypeTextToFilms < ActiveRecord::Migration
  def change
    add_column :films, :picture_text, :boolean
  end
end
