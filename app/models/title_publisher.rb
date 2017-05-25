class TitlePublisher < ActiveRecord::Base

  def ==(another)
    self.class == another.class && self.name == another.type_and_location && self.publisher_type == another.publisher_type
  end
end
