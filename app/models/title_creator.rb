class TitleCreator < ActiveRecord::Base

  def ==(another)
    another.class == self.class && self.role == another.role && self.name == another.name
  end

end
