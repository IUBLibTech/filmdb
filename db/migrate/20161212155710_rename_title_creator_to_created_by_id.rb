class RenameTitleCreatorToCreatedById < ActiveRecord::Migration
  def up
    rename_column :titles, :creator, :created_by_id
    change_column :titles, :created_by_id, :integer, limit: 8
  end

  def down
    change_column :titles, :created_by_id, :string
    rename_column :titles, :created_by_id, :creator
  end
end
