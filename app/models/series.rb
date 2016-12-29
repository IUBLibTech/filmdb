class Series < ActiveRecord::Base
  has_many :titles, autosave: true
  belongs_to :creator, class_name: "User", foreign_key: "created_by_id", autosave: true
  belongs_to :modifier, class_name: "User", foreign_key: "modified_by_id", autosave: true
end
