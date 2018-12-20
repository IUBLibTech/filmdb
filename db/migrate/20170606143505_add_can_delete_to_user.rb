class AddCanDeleteToUser < ActiveRecord::Migration
  def change
    add_column :users, :can_delete, :boolean, default: false
  end
end
