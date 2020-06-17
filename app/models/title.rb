class Title < ActiveRecord::Base
	include DateHelper
	include PhysicalObjectsHelper
	include SessionsHelper

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

	# mysql bad handshake causing the direct DB lookup to no longer work - MySQL 5.5 vs 5.1 coupled with Mysql2 gem being compiled against 5.5
	#has_one :pod_group_key, class_name: "PodGroupKey", foreign_key: "filmdb_title_id"

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
      "WHERE EXISTS (SELECT 1 FROM component_groups WHERE group_type in ('Best Copy (MDPI)', 'Reformatting (MDPI)', 'Best Copy (MDPI - WELLS)'))) ORDER BY title_text"
    Title.find_by_sql(sql)
  }
  scope :titles_not_selected_for_digitization, -> {
    sql = "SELECT * FROM titles WHERE id not in ("+
      "(SELECT titles.id FROM titles WHERE titles.id in ("+
      "SELECT distinct(titles.id) FROM workflow_statuses inner join component_groups on workflow_statuses.component_group_id = component_groups.id "+
      "inner join physical_objects on workflow_statuses.physical_object_id = physical_objects.id inner join physical_object_titles on "+
      "physical_objects.id = physical_object_titles.physical_object_id inner join titles on physical_object_titles.title_id = titles.id "+
      "WHERE EXISTS (SELECT 1 FROM component_groups WHERE group_type in ('Best Copy (MDPI)', 'Reformatting (MDPI)', 'Best Copy (MDPI - WELLS)'))))) ORDER BY title_text"
    Title.find_by_sql(sql)
  }

  scope :title_search, -> (title_text, series_name_text, date, publisher_text, creator_text, summary_text, location_text, subject_text, collection_id, current_user, offset, limit) {
	  connection.execute("DROP TABLE IF EXISTS #{current_user}_title_search")
	  tempTblSql = "CREATE TEMPORARY TABLE #{current_user}_title_search as (SELECT distinct(titles.id) as title_id "+
		  "#{title_search_from_sql(title_text, series_name_text, date, publisher_text, creator_text, summary_text, location_text, subject_text, collection_id)} "+
		  "#{title_search_where_sql(title_text, series_name_text, date, publisher_text, creator_text, summary_text, location_text, subject_text, collection_id)})"
	  connection.execute(tempTblSql)
	  sql = "SELECT titles.* FROM titles INNER JOIN #{current_user}_title_search WHERE titles.id = #{current_user}_title_search.title_id ORDER BY titles.title_text LIMIT #{limit} OFFSET #{offset}"
	  res = Title.find_by_sql(sql)
	  connection.execute("DROP TABLE #{current_user}_title_search")
	  res
  }
	scope :title_search_count, -> (title_text, series_name_text, date, publisher_text, creator_text, summary_text, location_text, subject_text, collection_id, current_user, offset, limit) {
		connection.execute("DROP TABLE IF EXISTS #{current_user}_title_search")
		tempTblSql = "CREATE TEMPORARY TABLE #{current_user}_title_search as (SELECT distinct(titles.id) as title_id "+
			"#{title_search_from_sql(title_text, series_name_text, date, publisher_text, creator_text, summary_text, location_text, subject_text, collection_id)} "+
			"#{title_search_where_sql(title_text, series_name_text, date, publisher_text, creator_text, summary_text, location_text, subject_text, collection_id)})"
		connection.execute(tempTblSql)
		sql = "SELECT count(*) FROM titles INNER JOIN #{current_user}_title_search WHERE titles.id = #{current_user}_title_search.title_id ORDER BY titles.title_text LIMIT #{limit} OFFSET #{offset}"
		res = connection.execute(sql)
		connection.execute("DROP TABLE #{current_user}_title_search")
		res.first.nil? ? 0 :	res.first[0]
	}

	scope :titles_without_physical_objects, -> {
		Title.find_by_sql("select * from titles where id not in (select title_id from physical_object_titles)")
	}

	scope :count_titles_without_physical_objects, -> {
		res = connection.execute("select count(distinct(id)) from titles where id not in (select title_id from physical_object_titles)")
		res.first.nil? ? 0 : res.first[0]
	}

	def self.per_page
		100
	end

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
			"WHERE physical_object_titles.title_id = #{self.id} AND component_groups.group_type in ('Best Copy (MDPI - Wells)', 'Reformatting (MDPI)', 'Best Copy (MDPI)' )"
		ActiveRecord::Base.connection.execute(sql).first[0]
	end

	def digitized?
		physical_objects.any?{ |p| p.digitized? }
	end

	def mods_extent(po)
		cgs = po.component_groups.where(title_id: self.id)
		if cgs.nil? || cgs.size == 0
			# we don't have workflow history so make a best guess based on medium of po
			calc_extent_from_po_medium po
		else
			possible = WorkflowStatus.where(status_name: WorkflowStatus::SHIPPED_EXTERNALLY, component_group_id: cgs.collect { |cg| cg.id }).first
			if possible.nil?
				# we don't have workflow history so make a best guess based on medium of po
				calc_extent_from_po_medium po
			else
				# we have a CG that was Shipped Externally - the best we can know about whether something was digitized
				pos = ComponentGroup.find(possible.component_group_id).physical_objects
				"#{pos.size} #{po.medium.pluralize(pos.size)} (#{ self.duration_of_specific pos }); "+"#{ pos.collect{|p| p.specific.has_attribute?(:gauge) ? p.specific.gauge : ''}.uniq.join(', ')}"
			end
		end
	end
	def calc_extent_from_po_medium(po)
		pos = physical_objects.where(medium: po.medium)
		"#{pos.size} #{po.medium.pluralize(pos.size)} (#{ self.duration_of_specific pos }); "+"#{  pos.collect{|p| p.specific.has_attribute?(:gauge) ? p.specific.gauge : ''}.uniq.join(', ')}}"
	end

	def in_active_workflow?
		physical_objects.any?{ |p|
			cs = p.current_workflow_status
			(!cs.nil? && !WorkflowStatus.is_storage_status?(cs.status_name)) &&	cs.status_name != WorkflowStatus::JUST_INVENTORIED_ALF && cs.status_name != WorkflowStatus::JUST_INVENTORIED_WELLS
		}
	end

	def associated_titles
		titles = []
		physical_objects.each do |p|
			tos = p.titles
			titles += (tos.to_a - [self])
		end
		titles.uniq.sort{|t1,t2| t1.title_text <=> t2.title_text}
	end

	# calculates the total duration of all PhysicalObjects in hh:mm:ss format
	def total_duration
		hh_mm_sec physical_objects.inject(0){|sum, p| p[:duration].to_i + sum }
	end
	# calculates the total duration of all PhysicalObjects with the specified 'medium' med, in hh:mm:ss format
	def medium_duration(med)
		hh_mm_sec physical_objects.where(medium: med).inject(0){|sum, p| p[:duration] ? p[:duration].to_i + sum : 0 + sum }
	end
	# calculates the total duration of PhysicalObjects in po_list in hh:mm:ss format
	def duration_of_specific(po_list)
		hh_mm_sec po_list.inject(0){|sum, p| p[:duration] ? p[:duration].to_i + sum : 0 + sum }
	end

	# connects to POD to generate a URL for Dark Avalon if one exists. Because this is communication over an HTTP requests,
	# returns a hash containing important information related to the success of the GET. There are 3 different possible
	# outcomes with different hash contents:
	# 1) communication with POD was successful and a URL was determined. The hash contains [status: 200, url: <the url>]
	# 2) the title doesn't have any digitized PO's so there won't be an Avalon URL anyway: the hash is empty {}
	# 3) network communication problems (down servers, 5xx HTTP codes, etc): the hash contains: {error: <some message>}
	#
	def avalon_url
		po = self.physical_objects.where(digitized: true).first
		if po.nil?
			{}
			else
				begin
					gk = Title.pod_group_key_id(po.mdpi_barcode)
					if gk[:status] != 200
						{error: "Error connecting to POD. Status: #{gk[:status]}"}
					else
						gk = gk[:gid]
						self.update(pod_group_key_identifier: gk.to_i)
						u = Rails.application.secrets[:pod_services_avalon_url].dup.gsub!(':gki', pod_group_key_identifier.to_s)
						uri = URI.parse(u)
						http = Net::HTTP.new(uri.host, uri.port)
						http.use_ssl = true
						request = Net::HTTP::Get.new(uri.request_uri)
						request.basic_auth(Rails.application.secrets[:pod_service_username], Rails.application.secrets[:pod_service_password])
						result = http.request(request).body.gsub(/\s+/, "")
						url = result.match(/<message>(.*?)<\/message>/)[1]
						if url.nil?
							{error: "Could not find an Avalon URL"}
						else
							{url: url}
						end
					end
				rescue => e
					puts e.message
					puts e.backtrace.join('\n')
					{error: "An unexpected error occurred while retrieving the Avalon URL from POD: #{e.message}"}
				end
		end
	end

	private
	# looks up POD group key identifier (GR000xxx) and converts it to its database ID value: GR000...xxx stripping away
	# the GR and leading zeroes. Returning a hash with two keys: status which is the HTTP status code of the request, and gid
	# which is the group id in POD IFF status is 200
	def self.pod_group_key_id(mdpi_barcode)
		u = Rails.application.secrets[:pod_service_grouping_url].dup.gsub!(':mdpi_barcode', mdpi_barcode.to_s)
		uri = URI.parse(u)
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true
		request = Net::HTTP::Get.new(uri.request_uri)
		request.basic_auth(Rails.application.secrets[:pod_service_username], Rails.application.secrets[:pod_service_password])
		result = http.request(request)
		code = result.code.to_i
		if code == 200
			body = result.body
			gr = body.match(/<group_identifier>(GR[0]+)([1-9][0-9]*)<\/group_identifier>/)[2]
			raise "Missing Group Identifier: #{result}" if gr.nil?
			{status: code, gid: gr}
		else
			{status: code, gid: nil}
		end
	end

	def self.title_search_from_sql(title_text, series_name_text, date, publisher_text, creator_text, summary_text, location_text, subject_text, collection_id)
		sql = "FROM titles"
		if !series_name_text.blank?
			sql << " INNER JOIN series on titles.series_id = series.id"
		end
		if !date.blank?
			sql << " INNER JOIN title_dates ON title_dates.title_id = titles.id"
		end
		if !publisher_text.blank?
			sql << " INNER JOIN title_publishers ON title_publishers.title_id = titles.id"
		end
		if !creator_text.blank?
			sql << " INNER JOIN title_creators ON title_creators.title_id = titles.id"
		end
		if !location_text.blank?
			sql << " INNER JOIN title_locations ON title_locations.title_id = titles.id"
		end
		if !collection_id.blank?
			sql << " INNER JOIN physical_object_titles ON physical_object_titles.title_id = titles.id "+
				"INNER JOIN physical_objects ON physical_objects.id = physical_object_titles.physical_object_id "+
				"INNER JOIN collections ON physical_objects.collection_id = collections.id"
		end
		sql
	end
	def self.title_search_where_sql(title_text, series_name_text, date, publisher_text, creator_text, summary_text, location_text, subject_text, collection_id)
		sql = (title_text.blank? && series_name_text.blank? && date.blank? && publisher_text.blank? && creator_text.blank? && summary_text.blank? && location_text.blank? && subject_text.blank? && collection_id.blank?) ? "" : "WHERE"
		if !title_text.blank?
			sql << " titles.title_text like #{escape_wildcard(title_text)}"
		end
		if !series_name_text.blank?
			add_and(sql)
			sql << " series.title like #{escape_wildcard(series_name_text)}"
		end
		if !date.blank?
			add_and(sql)
			dates = date.gsub(' ', '').split('-')
			if dates.size == 1
				sql << "((title_dates.end_date is null AND year(title_dates.start_date) = #{dates[0]}) OR "+
					"(title_dates.end_date is not null AND year(title_dates.start_date) <= #{dates[0]} AND year(title_dates.end_date) >=  #{dates[0]}))"
			else
				sql << "((title_dates.end_date is null AND year(title_dates.start_date) >= #{dates[0]} AND year(title_dates.start_date) <= #{dates[1]})  OR "+
					"(title_dates.end_date is not null AND "+
					"((year(title_dates.start_date) >= #{dates[0]} AND year(title_dates.start_date) <= #{dates[1]}) OR "+
					"(year(title_dates.end_date) >= #{dates[0]} AND year(title_dates.end_date) <= #{dates[1]}) OR "+
					"(year(title_dates.start_date) < #{dates[0]} AND year(title_dates.end_date) > #{dates[1]}))))"
			end
		end
		if !publisher_text.blank?
			add_and(sql)
			sql << "title_publishers.name like #{escape_wildcard(publisher_text)}"
		end
		if !creator_text.blank?
			add_and(sql)
			sql << "title_creators.name like #{escape_wildcard(creator_text)}"
		end
		if !summary_text.blank?
			add_and(sql)
			sql << "titles.summary like #{escape_wildcard(summary_text)}"
		end
		if !location_text.blank?
			add_and(sql)
			sql << "title_locations.location like #{escape_wildcard(location_text)}"
		end
		if !subject_text.blank?
			add_and(sql)
			sql << "titles.subject like #{escape_wildcard(subject_text)}"
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
	def self.escape_wildcard(value)
		ActiveRecord::Base.connection.quote("%#{value}%")
	end

end

























