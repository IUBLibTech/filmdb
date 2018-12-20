class AddGroupSummaryToComponentGroup < ActiveRecord::Migration
  def change
    add_column :component_groups, :group_summary, :text, limit: 65535
  end
end
