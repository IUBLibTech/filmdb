class AddTapeCapacityToVideo < ActiveRecord::Migration[5.0]
  def change
    add_column :videos, :tape_capacity, :string
  end
end
