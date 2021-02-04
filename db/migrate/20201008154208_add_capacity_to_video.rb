class AddCapacityToVideo < ActiveRecord::Migration
  def change
    add_column :recorded_sounds, :capacity, :string
  end
end
