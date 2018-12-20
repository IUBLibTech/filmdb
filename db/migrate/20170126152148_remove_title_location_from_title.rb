class RemoveTitleLocationFromTitle < ActiveRecord::Migration
  def up
    remove_column :titles, :location
  end
  def down
    add_column :titles, :location, :string
  end
end
