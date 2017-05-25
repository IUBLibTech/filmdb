class FirstChangeToWorkflowStatuses < ActiveRecord::Migration
  def change
    WorkflowStatus.all.delete_all
    WorkflowStatusTemplate.all.delete_all
    ['In Storage', 'Queued for Pull Request', 'Pull Requested', 'On Site', 'Shipped External' ].each_with_index do |s, i|
      WorkflowStatusTemplate.new(type_and_location: s, sort_order: i, description: '').save
    end
  end
end
