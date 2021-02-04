class AddInterpostiveGenerationToFilms < ActiveRecord::Migration
  def change
    add_column :films, :generation_interpositive, :boolean
  end
end
