class TitleDate < ActiveRecord::Base

  def ==(another)
    self.class == another.class && self.date == another.date && self.date_type == another.date_type
  end
end
