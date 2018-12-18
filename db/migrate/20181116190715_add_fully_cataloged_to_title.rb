class AddFullyCatalogedToTitle < ActiveRecord::Migration
  def change
    add_column :titles, :fully_cataloged, :boolean
  end
end
