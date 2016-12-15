class RenameOriginalIdentifierTypeToIdentifierType < ActiveRecord::Migration
  def up
    rename_column :title_original_identifiers, :type, :identifier_type
  end

  def down
    rename_column :title_original_identifiers, :identifier_type, :type
  end
end
