class AddNameAuthorityToTitles < ActiveRecord::Migration
  def change
    add_column :titles, :name_authority, :text, limit: 65535
  end
end
