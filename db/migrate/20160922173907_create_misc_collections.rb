class CreateMiscCollections < ActiveRecord::Migration
  def up
    Unit.all.each do |u|
      if u.collections.where(name: Collection::MISC_COLLECTION_NAME).first.nil?
        collection = Collection.new(name: Collection::MISC_COLLECTION_NAME, unit_id: u.id)
        puts "Created Misc Collection for #{u.abbreviation}"
        collection.save
      end
    end
  end

  def down
    # cannot DOWN this one as new units may be created in the application and we don't want to delete those
  end
end
