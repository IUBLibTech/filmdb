class TitleGenre < ActiveRecord::Base

  def ==(another)
    self.class == another.class && self.genre == another.genre
  end
end
