class AddCapacityToVideo < ActiveRecord::Migration[5.0]
  def change
    add_column :recorded_sounds, :capacity, :string
  end
end
