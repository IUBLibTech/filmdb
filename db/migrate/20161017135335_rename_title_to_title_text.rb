class RenameTitleToTitleText < ActiveRecord::Migration
  def change
    rename_column :titles, :title, :title_text
  end
end
