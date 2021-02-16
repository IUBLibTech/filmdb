class ChangeTapeCapacityToInteger < ActiveRecord::Migration
  def up
    change_column :videos, :tape_capacity, :integer
  end

  def down
    change_column :videos, :tape_capacity, :string
  end
end
