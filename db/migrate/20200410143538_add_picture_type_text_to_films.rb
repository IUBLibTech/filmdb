class AddPictureTypeTextToFilms < ActiveRecord::Migration[5.0]
  def change
    add_column :films, :picture_text, :boolean
  end
end
