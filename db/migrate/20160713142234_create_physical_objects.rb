class CreatePhysicalObjects < ActiveRecord::Migration
  def change
    create_table :physical_objects do |t|

      t.timestamps
    end
  end
end
