class SetCanDeleteForAdmins < ActiveRecord::Migration
  def up
	  User.where(username: ['jaalbrec', 'carton', 'jauhrich', 'rstoeltj']).update_all(can_delete: true)
  end

  def down
	  User.where(username: ['jaalbrec', 'carton', 'jauhrich', 'rstoeltj']).update_all(can_delete: false)
  end
end
