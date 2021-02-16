class Add2551AspectRatioToFilms < ActiveRecord::Migration
  def change
    add_column :films, :aspect_ratio_2_55_1, :boolean
  end
end
