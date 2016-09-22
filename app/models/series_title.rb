class SeriesTitle < ActiveRecord::Base
  has_many :titles
  belongs_to :series
end
