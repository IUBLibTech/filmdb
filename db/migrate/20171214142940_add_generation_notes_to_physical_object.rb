class AddGenerationNotesToPhysicalObject < ActiveRecord::Migration
  def change
    add_column :physical_objects, :generation_notes, :text, limit: 65535
  end
end
