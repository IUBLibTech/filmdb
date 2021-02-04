class CopyPoCreatedAtIntoInventoryDate < ActiveRecord::Migration
  def up
    ActiveRecord::Base.connection.execute("update physical_objects set date_inventoried = created_at")
  end
  def down
    # date inventoried is not currently being used so rolling back should set this value to null
    ActiveRecord::Base.connection.execute("update physical_objects set date_inventoried = null")
  end
end
