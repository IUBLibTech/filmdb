class RemoveMiscCollections < ActiveRecord::Migration
  def change
    Collection.where(name: 'Misc [not in collection]').delete_all
  end
end
