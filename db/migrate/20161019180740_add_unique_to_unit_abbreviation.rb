class AddUniqueToUnitAbbreviation < ActiveRecord::Migration
  def change
    add_index :units, :abbreviation, unique: true
  end

end
