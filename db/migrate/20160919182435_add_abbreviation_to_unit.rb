class AddAbbreviationToUnit < ActiveRecord::Migration
  def change
    add_column :units, :abbreviation, :string, null: false
    add_column :units, :institution, :string, null: false
    add_column :units, :campus, :string
  end
end
