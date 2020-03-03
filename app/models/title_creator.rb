class TitleCreator < ActiveRecord::Base
  belongs_to :title
  def ==(another)
    another.class == self.class && self.role == another.role && self.name == another.name
  end

end
