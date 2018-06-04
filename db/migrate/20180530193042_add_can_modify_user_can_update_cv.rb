class AddCanModifyUserCanUpdateCv < ActiveRecord::Migration
  def change
    add_column :users, :can_edit_users, :boolean, default: false
    add_column :users, :can_add_cv, :boolean, default: false

    User.reset_column_information
    %w(jaalbrec carcurt abertin).each do |u|
      User.where(username: u).first.update_attributes!(can_edit_users: true, can_add_cv: true)
    end
  end
end
