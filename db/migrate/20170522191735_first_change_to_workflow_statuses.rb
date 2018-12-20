class FirstChangeToWorkflowStatuses < ActiveRecord::Migration
  def change
    WorkflowStatus.all.delete_all
  end
end
