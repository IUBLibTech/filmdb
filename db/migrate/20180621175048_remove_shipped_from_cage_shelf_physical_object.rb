class RemoveShippedFromCageShelfPhysicalObject < ActiveRecord::Migration
  def up
    remove_column :cage_shelf_physical_objects, :shipped
    add_column :cage_shelves, :shipped, :datetime
    add_column :cage_shelves, :returned_date, :datetime
    batches = PodBatch.where(format: 'Film')
    batches.each_with_index do |b, i|
      puts "Processing Batch #{i + 1 } of #{batches.size}"
      CageShelf.where(identifier: b.identifier).first.update_attributes!(shipped: b.created_at)
    end
  end

  def down
    remove_column :cage_shelves, :shipped
    remove_column :cage_shelves, :returned_date
    add_column :cage_shelf_physical_objects, :shipped, :datetime
  end
end
