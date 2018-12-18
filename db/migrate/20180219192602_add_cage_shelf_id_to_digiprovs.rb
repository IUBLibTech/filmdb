class AddCageShelfIdToDigiprovs < ActiveRecord::Migration
  def change
    add_column :digiprovs, :cage_shelf_id, :integer, limit: 8
  end
end
