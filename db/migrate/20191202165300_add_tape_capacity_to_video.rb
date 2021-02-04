class AddTapeCapacityToVideo < ActiveRecord::Migration
  def change
    add_column :videos, :tape_capacity, :string
  end
end
