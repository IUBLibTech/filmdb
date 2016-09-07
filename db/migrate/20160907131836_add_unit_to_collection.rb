class AddUnitToCollection < ActiveRecord::Migration
  def change
    add_column :collections, :unit_id, :integer, limit: 8
  end
end
