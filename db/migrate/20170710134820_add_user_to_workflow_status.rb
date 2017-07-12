class AddUserToWorkflowStatus < ActiveRecord::Migration
  def change
    add_column :workflow_statuses, :created_by, :integer, limit: 8
  end
end
