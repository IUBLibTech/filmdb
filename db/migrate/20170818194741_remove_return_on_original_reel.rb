class RemoveReturnOnOriginalReel < ActiveRecord::Migration
  def change
    remove_column :component_groups, :return_on_original_reel
  end
end
