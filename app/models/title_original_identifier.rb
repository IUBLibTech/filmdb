class TitleOriginalIdentifier < ActiveRecord::Base

  def ==(another)
    self.class == another.class && self.identifier == another.identifier && self.identifier_type == another.identifier_type
  end
end
