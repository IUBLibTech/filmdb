class AddColorSpaceToComponentGroup < ActiveRecord::Migration
  def change
    add_column :component_groups, :color_space, :string
  end
end
