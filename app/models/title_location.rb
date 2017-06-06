class TitleLocation < ActiveRecord::Base

  def ==(another)
    self.class == another.class && self.location == another.location
  end
end
