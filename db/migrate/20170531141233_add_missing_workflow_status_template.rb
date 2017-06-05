class AddMissingWorkflowStatusTemplate < ActiveRecord::Migration
  def change
    WorkflowStatusTemplate.new(name: 'Missing', sort_order: 5, description: "The item cannot be found in it's last location").save
  end
end
