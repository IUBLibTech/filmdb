class Title < ActiveRecord::Base
	include DateHelper

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

  scope :titles_selected_for_digitization, -> {
    sql = "SELECT titles.* FROM titles WHERE titles.id in ("+
      "SELECT distinct(titles.id) FROM workflow_statuses inner join component_groups on workflow_statuses.component_group_id = component_groups.id "+
      "inner join physical_objects on workflow_statuses.physical_object_id = physical_objects.id inner join physical_object_titles on "+
      "physical_objects.id = physical_object_titles.physical_object_id inner join titles on physical_object_titles.title_id = titles.id "+
      "WHERE EXISTS (SELECT 1 FROM component_groups WHERE group_type in ('Best Copy (MDPI)', 'Reformatting (MDPI)', 'Reformatting Replacement (MDPI)'))) ORDER BY title_text"
    Title.find_by_sql(sql)
  }
  scope :titles_not_selected_for_digitization, -> {
    sql = "SELECT * FROM titles WHERE id not in ("+
      "(SELECT titles.id FROM titles WHERE titles.id in ("+
      "SELECT distinct(titles.id) FROM workflow_statuses inner join component_groups on workflow_statuses.component_group_id = component_groups.id "+
      "inner join physical_objects on workflow_statuses.physical_object_id = physical_objects.id inner join physical_object_titles on "+
      "physical_objects.id = physical_object_titles.physical_object_id inner join titles on physical_object_titles.title_id = titles.id "+
      "WHERE EXISTS (SELECT 1 FROM component_groups WHERE group_type in ('Best Copy (MDPI)', 'Reformatting (MDPI)', 'Reformatting Replacement (MDPI)'))))) ORDER BY title_text"
    Title.find_by_sql(sql)
  }

  scope :title_search, -> (title_text, date, publisher_text, collection_id) {
	  sql = "SELECT titles.* FROM titles WHERE titles.id in ( SELECT distinct(titles.id) "+
		  "#{title_search_from_sql(title_text, date, publisher_text, collection_id)} "+
		  "#{title_search_where_sql(title_text, date, publisher_text, collection_id)}) ORDER BY titles.title_text"

	  puts "\n\n\n#{sql}\n\n\n"
	  Title.find_by_sql(sql)
  }

	def series_title_text
		self.series.title if self.series
  end

  def alternative_titles
    PhysicalObject.joins(:physical_object_titles).where(physical_object_titles: {title_id: id}).pluck(:alternative_title).uniq
  end

	def count_selected_for_digitization
		sql = "SELECT count(distinct(physical_objects.id)) "+"
		FROM physical_objects INNER JOIN physical_object_titles ON physical_objects.id = physical_object_titles.physical_object_id "+
			"INNER JOIN workflow_statuses on physical_objects.id = workflow_statuses.physical_object_id "+
			"INNER JOIN component_groups ON workflow_statuses.component_group_id = component_groups.id "+
			"WHERE physical_object_titles.title_id = #{self.id} AND component_groups.group_type in ('Best Copy (MDPI)', 'Reformatting (MDPI)', 'Reformatting Replacement (MDPI)' )"
		ActiveRecord::Base.connection.execute(sql).first[0]
	end

	def in_active_workflow?
		physical_objects.any?{ |p|
			cs = p.current_workflow_status
			(!cs.nil? && !WorkflowStatus.is_storage_status?(cs.status_name)) &&	cs.status_name != WorkflowStatus::JUST_INVENTORIED_ALF && cs.status_name != WorkflowStatus::JUST_INVENTORIED_WELLS
		}
	end

	private
	def self.title_search_from_sql(title_text, date, publisher_text, collection_id)
		sql = "FROM titles"
		if !date.blank?
			sql << " INNER JOIN title_dates ON title_dates.title_id = titles.id"
		end
		if !publisher_text.blank?
			sql << " INNER JOIN title_publishers ON title_publishers.title_id = titles.id"
		end
		if !collection_id.blank?
			sql << " INNER JOIN physical_object_titles ON physical_object_titles.title_id = titles.id "+
				"INNER JOIN physical_objects ON physical_objects.id = physical_object_titles.physical_object_id "+
				"INNER JOIN collections ON physical_objects.collection_id = collections.id"
		end
		sql
	end
	def self.title_search_where_sql(title_text, date, publisher_text, collection_id)
		sql = (title_text.blank? && date.blank? && publisher_text.blank? && collection_id.blank?) ? "" : "WHERE"
		if !title_text.blank?
			sql << " titles.title_text like '%#{title_text}%'"
		end
		if !date.blank?
			add_and(sql)
			dates = date.gsub(' ', '').split('-')
			if dates.size == 1
				sql << "((title_dates.end_date is null AND year(title_dates.start_date) = #{dates[0]}) OR "+
					"(title_dates.end_date is not null AND year(title_dates.start_date) <= #{dates[0]} AND year(title_dates.end_date) >=  #{dates[0]}))"
			else
				sql << "((title_dates.end_date is null AND #{dates[0]} <= year(title_dates.start_date) AND #{dates[0]} >= year(title_dates.start_date)) OR "+
					"(title_dates.end_date is not null AND "+
					"((#{dates[0]} <= year(title_dates.start_date) AND #{dates[1]} >= year(title_dates.start_date)) OR "+
					"(#{dates[0]} <= year(title_dates.end_date) AND #{dates[1]} >= year(title_dates.end_date)) OR "+
					"(year(title_dates.start_date) < #{dates[0]} AND year(title_dates.end_date) > #{dates[1]}))))"
			end
		end
		if !publisher_text.blank?
			add_and(sql)
			sql << "title_publishers.name like '%#{publisher_text}%'"
		end
		if !collection_id.blank?
			add_and(sql)
			sql << "collections.id = #{collection_id}"
		end
		sql
	end
	def self.add_and(sql)
		sql << ((sql.length > "WHERE ".length) ? ' AND ' : ' ')
	end

end

























