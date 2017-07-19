class AddAmberToUsers < ActiveRecord::Migration
  def change
    User.new(username: 'abertin', first_name: 'Amber', last_name: 'Bertin', email_address: 'abertin@indiana.edu', can_delete: true, works_in_both_locations: true, active: true).save
  end
end
