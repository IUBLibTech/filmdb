class AddWorksiteLocationToUser < ActiveRecord::Migration
  def change
    add_column :users, :worksite_location, :string
  end
end
