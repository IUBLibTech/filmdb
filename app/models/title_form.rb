class TitleForm < ActiveRecord::Base

  def ==(another)
    self.class == another.class && self.form == another.form
  end
end
