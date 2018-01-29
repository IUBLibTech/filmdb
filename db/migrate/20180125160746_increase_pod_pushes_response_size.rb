class IncreasePodPushesResponseSize < ActiveRecord::Migration
  def up
    change_column :pod_pushes, :response, :text, :limit => 4294967295
  end
  def down

  end
end
