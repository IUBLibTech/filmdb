class AddIndexOnPhysicalObjectIdToWorkflowStatuses < ActiveRecord::Migration
  def change
    add_index :workflow_statuses, :physical_object_id
  end
end
