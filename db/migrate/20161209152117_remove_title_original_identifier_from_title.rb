class RemoveTitleOriginalIdentifierFromTitle < ActiveRecord::Migration
  def up
    remove_column :titles, :title_original_identifier
  end

  def down
    add_column :titles, :title_original_identifier, :string
  end
end
