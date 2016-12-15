class Title < ActiveRecord::Base
	has_many :physical_objects
  has_many :title_creators, dependent: :delete_all
  has_many :title_dates, dependent: :delete_all
  has_many :title_genres, dependent: :delete_all
  has_many :title_original_identifiers, dependent: :delete_all
  has_many :title_publishers, dependent: :delete_all

	belongs_to :series
	belongs_to :spreadsheet
  belongs_to :creator, class_name: "User", foreign_key: "created_by_id"
  belongs_to :modifier, class_name: "User", foreign_key: "modified_by_id"

  accepts_nested_attributes_for :title_creators, allow_destroy: true
  accepts_nested_attributes_for :title_dates, allow_destroy: true
  accepts_nested_attributes_for :title_genres, allow_destroy: true
  accepts_nested_attributes_for :title_original_identifiers, allow_destroy: true
  accepts_nested_attributes_for :title_publishers, allow_destroy: true

	def series_title_text
		self.series.title if self.series
	end
end
