class CreatePhysicalObjects < ActiveRecord::Migration
  def change
    create_table :physical_objects do |t|

      t.timestamps null: false
    end
  end
end
