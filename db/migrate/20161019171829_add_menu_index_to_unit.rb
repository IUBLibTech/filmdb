class AddMenuIndexToUnit < ActiveRecord::Migration
  def change
    add_column :units, :menu_index, :integer, null: true
  end
end
