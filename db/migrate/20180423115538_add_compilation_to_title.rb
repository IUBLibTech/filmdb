class AddCompilationToTitle < ActiveRecord::Migration
  def change
    add_column :titles, :compilation, :text
  end
end
