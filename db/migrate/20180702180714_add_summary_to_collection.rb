class AddSummaryToCollection < ActiveRecord::Migration
  def change
    add_column :collections, :summary, :text, limit: 65535
  end
end
