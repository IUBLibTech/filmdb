class AddIndexOnWorkflowStatusesStatusName < ActiveRecord::Migration
  def change
    add_index :workflow_statuses, :status_name
  end
end
