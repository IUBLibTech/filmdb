class ChangeTapeCapacityToInteger < ActiveRecord::Migration[5.0]
  def up
    change_column :videos, :tape_capacity, :integer
  end

  def down
    change_column :videos, :tape_capacity, :string
  end
end
