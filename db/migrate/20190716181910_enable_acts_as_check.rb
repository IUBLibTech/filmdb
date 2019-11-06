class EnableActsAsCheck < ActiveRecord::Migration
  # this does not alter any table structure in the database, it serves as a check to ensure that once the film metadata
  # has been copied from the PhysicalObject table into the Film table, that the acts_as gem is enabled on Films.

  def up
    if Film.is_a? PhysicalObject
      puts "Films are correctly configured to act as Physical Objects. Continuing with migrations"
    else
      raise "Films are not configured correctly to act as Physical Objects - uncomment Film 'acts_as' and PhysicalObject 'actable'."
    end
  end

  def down
    # there is no reverse action to this.
  end
end
