class AddLocationIdToworkflowStatus < ActiveRecord::Migration

  def change
    add_column :workflow_statuses, :workflow_status_location_id, :integer, limit: 8
  end

end
