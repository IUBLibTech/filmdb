class Title < ActiveRecord::Base
	#has_many :physical_objects, autosave: true
  has_many :title_creators, dependent: :delete_all, autosave: true
  has_many :title_dates, dependent: :delete_all, autosave: true
  has_many :title_genres, dependent: :delete_all, autosave: true
  has_many :title_forms, dependent: :delete_all, autosave: true
  has_many :title_original_identifiers, dependent: :delete_all, autosave: true
  has_many :title_publishers, dependent: :delete_all, autosave: true
  has_many :title_dates, dependent: :delete_all, autosave: true
  has_many :title_locations, dependent: :delete_all, autosave: true

  has_many :physical_object_titles, dependent: :delete_all
  has_many :physical_objects, through: :physical_object_titles
  has_many :component_groups

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

  # returns an array of distinct titles that appear in the specified spreadsheet
  scope :title_text_in_spreadsheet, -> (ss_id) {
    Title.select(:title_text).where(spreadsheet_id: ss_id).distinct.pluck(:title_text)
  }
  # returns an array of distinct tiltes that appear both in the specified spreadsheet but also outside (created in a different spreadsheet or created manually)
  scope :title_text_not_in_spreadsheet, -> (title_text, ss_id) {
    Title.select(:title_text).where('spreadsheet_id IS NULL OR spreadsheet_id != ?',ss_id).distinct.pluck(:title_text)
  }

  # returns a map of Title title_text to the number of titles in the specified spreadsheet that have that title
  scope :title_text_count_in_spreadsheet, -> (ss_id) {
    Title.where(spreadsheet_id: ss_id).group(:title_text).count
  }

  # retuns a map of Title title_text to count of those titles with title_text both in the specified spreadsheet and not in (created in a different spreadsheet or manually)
  scope :title_text_count_not_in_spreadsheet, -> (ss_id) {
    titles_in = Title.title_text_in_spreadsheet(ss_id)
    Title.where(title_text: titles_in).where('spreadsheet_id IS NULL OR spreadsheet_id != ?', ss_id).group(:title_text).count
  }

  scope :title_text_count_in_series, -> (series_id) {
    Title.where(series_id: series_id).group('title_text').count
  }
  scope :title_text_count_not_in_series, -> (series_id) {
    titles_in = Title.select(:title_text).where(series_id: series_id).distinct.pluck(:title_text)
    Title.where(title_text: titles_in).where('series_id IS NULL OR series_id != ?', series_id).group(:title_text).count
  }

  scope :titles_in_spreadsheet, -> (title_text, ss_id) {
    Title.where(spreadsheet_id: ss_id).where(title_text: title_text)
  }

  scope :titles_not_in_spreadsheet, -> (title_text, ss_id) {
    Title.where(title_text: title_text).where('spreadsheet_id IS NULL OR spreadsheet_id != ?', ss_id)
  }

	def series_title_text
		self.series.title if self.series
  end

  def alternative_titles
    PhysicalObject.joins(:physical_object_titles).where(physical_object_titles: {title_id: id}).pluck(:alternative_title).uniq
  end
end
