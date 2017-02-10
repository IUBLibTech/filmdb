class Title < ActiveRecord::Base
	has_many :physical_objects, autosave: true
  has_many :title_creators, dependent: :delete_all, autosave: true
  has_many :title_dates, dependent: :delete_all, autosave: true
  has_many :title_genres, dependent: :delete_all, autosave: true
  has_many :title_forms, dependent: :delete_all, autosave: true
  has_many :title_original_identifiers, dependent: :delete_all, autosave: true
  has_many :title_publishers, dependent: :delete_all, autosave: true
  has_many :title_dates, dependent: :delete_all, autosave: true
  has_many :title_locations, dependent: :delete_all, autosave: true

	belongs_to :series, autosave: true
	belongs_to :spreadsheet, autosave: true
  belongs_to :creator, class_name: "User", foreign_key: "created_by_id", autosave: true
  belongs_to :modifier, class_name: "User", foreign_key: "modified_by_id", autosave: true

  accepts_nested_attributes_for :title_creators, allow_destroy: true
  accepts_nested_attributes_for :title_dates, allow_destroy: true
  accepts_nested_attributes_for :title_genres, allow_destroy: true
  accepts_nested_attributes_for :title_original_identifiers, allow_destroy: true
  accepts_nested_attributes_for :title_publishers, allow_destroy: true
  accepts_nested_attributes_for :title_forms, allow_destroy: true
  accepts_nested_attributes_for :title_locations, allow_destroy: true

  scope :title_count_not_in_spreadsheet, -> (title_text, ss_id) {
    Title.where('(spreadsheet_id IS NULL OR spreadsheet_id != ?) AND title_text = ?',ss_id, title_text)
  }
  scope :titles_in_spreadsheet, -> (title_text, ss_id) {
    Title.where(title_text: title_text, spreadsheet_id: ss_id)
  }

	def series_title_text
		self.series.title if self.series
  end

  def alternative_titles
    PhysicalObject.where(title_id: self.id).pluck(:alternative_title).uniq
  end
end
