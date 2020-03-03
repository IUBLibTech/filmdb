class TitleGenre < ActiveRecord::Base
  belongs_to :title
  def ==(another)
    self.class == another.class && self.genre == another.genre
  end
end
