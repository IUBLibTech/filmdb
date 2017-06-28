class AddCleanToComponentGroup < ActiveRecord::Migration
  def change
    add_column :component_groups, :clean, :boolean, default: true
  end
end
