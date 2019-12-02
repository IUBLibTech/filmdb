class DropDurationFromVideo < ActiveRecord::Migration
  def up
    remove_column :videos, :duration
  end

  def down
    add_column :videos, :duration, :integer
  end
end
