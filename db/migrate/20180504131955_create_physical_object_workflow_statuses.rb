class CreatePhysicalObjectWorkflowStatuses < ActiveRecord::Migration
  def change
    add_column :physical_objects, :current_workflow_status_id, :integer, limit: 8
    add_index :physical_objects, :current_workflow_status_id

    count = PhysicalObject.all.size
    PhysicalObject.all.each_with_index do |p, i|
      puts "#{i} of #{count}"
      p.update_attributes(current_workflow_status_id: p.workflow_statuses.last.id)
    end
  end
end
