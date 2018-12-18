class AddSubjectToTitles < ActiveRecord::Migration
  def change
    add_column :titles, :subject, :text, limit: 65535
  end
end
