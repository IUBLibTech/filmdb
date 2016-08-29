class UserUsernameToEmail < ActiveRecord::Migration
  def change
    add_column :users, :email_address, :string, unique: true
  end
end
