class AddInterpostiveGenerationToFilms < ActiveRecord::Migration[5.0]
  def change
    add_column :films, :generation_interpositive, :boolean
  end
end
