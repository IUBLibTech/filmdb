class TitleLocation < ActiveRecord::Base
  belongs_to :title
  def ==(another)
    self.class == another.class && self.location == another.location
  end
end
