class AddCountryOfOriginToTitles < ActiveRecord::Migration
  def change
    add_column :titles, :country_of_origin, :text
  end
end
