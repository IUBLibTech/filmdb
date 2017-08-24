class AddReturnedToCageShelves < ActiveRecord::Migration
  def change
    add_column :cage_shelves, :returned, :boolean, default: false
  end
end
