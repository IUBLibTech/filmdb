class IncreaseTitleTextFieldSize < ActiveRecord::Migration
  def up
    change_column :titles, :title_text, :string, limit: 1024
  end

	def down
		change_column :titles, :title_text, :string, limit: 256
	end
end
