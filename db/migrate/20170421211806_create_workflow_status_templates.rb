class CreateWorkflowStatusTemplates < ActiveRecord::Migration
  def change
    create_table :workflow_status_templates do |t|
      t.string :name
      t.integer :sort_order
      t.text :description
      t.timestamps
    end
    ["Pull Request Queued", "Pull Request Processed", "Pull Request Received", "Shipped to Instition", "Returned From Institution", "In Storage"].each_with_index do |t, i|
      WorkflowStatusTemplate.new(
        name: t,
        sort_order: i,
        description: "A description of the workflow status (to be determined)"
      ).save
    end
  end
end
