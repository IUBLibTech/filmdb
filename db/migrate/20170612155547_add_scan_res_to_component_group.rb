class AddScanResToComponentGroup < ActiveRecord::Migration
  def change
    add_column :component_groups, :scan_resolution, :text, nil: true
  end
end
