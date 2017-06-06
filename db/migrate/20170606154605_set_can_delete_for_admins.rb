class SetCanDeleteForAdmins < ActiveRecord::Migration
  def up
	  ['jaalbrec', 'carton', 'jauhrich', 'rstoeltj'].each do |user|
	    User.where(username: user).update_all(can_delete: true)
    end
  end

  def down
	  ['jaalbrec', 'carton', 'jauhrich', 'rstoeltj'].each do |user|
		  User.where(username: user).update_all(can_delete: false)
	  end
  end
end
