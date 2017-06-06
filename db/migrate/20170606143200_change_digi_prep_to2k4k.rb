class ChangeDigiPrepTo2k4k < ActiveRecord::Migration
  def change
    WorkflowStatusLocation.where(physical_location: 'Digitization Prep').update_all(physical_location: '2k/4k Shelves')
  end
end
