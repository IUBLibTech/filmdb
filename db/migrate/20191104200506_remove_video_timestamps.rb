class RemoveVideoTimestamps < ActiveRecord::Migration[5.0]
  def change
    remove_column :videos, :created_at
    remove_column :videos, :updated_at
  end
end
