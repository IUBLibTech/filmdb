class CreateMdpiUser < ActiveRecord::Migration
  def up
    User.new(username: 'filmdb', first_name: "Filmdb", last_name: "User", active: true, can_delete: false, can_update_physical_object_location: false, email_address: 'filmdb@indiana.edu').save
  end

  def down
    # there is no spoon
  end
end
