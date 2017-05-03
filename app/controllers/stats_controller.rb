class StatsController < ApplicationController

	before_action :set_filters
	before_action :set_counts

	def index
	end

	def filter_index
		if (@startTime && !@endTime) || (@endTime && !@startTime)
			flash[:notice] = 'You only specified a single date, not a range'
		end
		render 'index'
	end

	def empty_titles

	end

	def empty_series

	end

	private
	def set_counts
		if any_filters?
			#if unit or collection are specified we have to go from physical object to title/series since
			# the associtions to unit/collect are through physical object and not title.
			@title_count = Title.find_by_sql(title_count_sql).size
			@physical_object_count = PhysicalObject.where(po_sql_where).size
			@empty_title_count = "N/A"
			@empty_series_count = "N/A"
			@series_count = Series.find_by_sql(series_count_sql).size
		else
			@title_count = Title.all.size
			@empty_title_count = Title.includes(:physical_object_titles).where(physical_object_titles: {title_id: nil}).size
			@series_count = Series.all.size
			@empty_series_count = Series.includes(:titles).where(titles: {id: nil}).size
			@physical_object_count = PhysicalObject.all.size
		end

		@media_type_count = PhysicalObject.where(po_sql_where).group(:media_type).count
		@medium_count = PhysicalObject.where(po_sql_where).group(:medium).count
		@generations = generations
		@gauges = PhysicalObject.where(po_sql_where).where("gauge is not null AND gauge != ''").group(:gauge).count
		@bases = bases
		@sounds = sounds
		@colors = colors
		@conditions = PhysicalObject.where(po_sql_where).where("condition_rating is not null and condition_rating != ''").group(:condition_rating).count
	end

	def any_filters?
		@unit || @collection || @startTime || @endTime
	end

	def set_filters
		unless params[:unit].blank? || params[:unit] == 0
			@unit = Unit.find(params[:unit])
		end
		unless params[:collection_id].blank? || params[:collection_id] == 0
			@collection = Collection.find(params[:collection_id])
		end
		unless params[:start].blank? || params[:start] == 0
			begin
				@startTime = DateTime.strptime(params[:start], "%m/%d/%Y")
			rescue
			end
			begin
				@endTime = DateTime.strptime(params[:end], "%m/%d/%Y") + 23.hours + 59.minutes + 59.seconds
			rescue
			end
		end
		@filter_msg = (@collection ? "[#{@collection.unit.abbreviation} - #{@collection.name}]" : (@unit ? "[#{@unit.abbreviation}]" : "[Gloabl]"))
	end

	def po_sql_where
		sql = @unit ? " unit_id = #{@unit.id}" : ""
		sql += @collection ? (sql.length > 0 ? " AND " : "")+"collection_id = #{@collection.id}" : ""
		sql += @startTime ? (sql.length > 0 ? " AND " : "")+"physical_objects.created_at >= '#{@startTime}' AND physical_objects.created_at <= '#{@endTime}' " : ""
		sql
	end

	def title_count_sql
		"select distinct(titles.id) from physical_objects, titles, physical_object_titles "+
			"where #{po_sql_where} and physical_objects.id = physical_object_titles.physical_object_id and physical_object_titles.title_id = titles.id"
	end

	def series_count_sql
		"SELECT distinct(series.id) FROM physical_objects, physical_object_titles, titles, series "+
			"WHERE #{po_sql_where} AND physical_objects.id = physical_object_titles.physical_object_id AND titles.id = physical_object_titles.title_id AND titles.series_id = series.id"
	end

	def generations
		gens = Hash.new
		PhysicalObject::GENERATION_FIELDS.each do |gf|
			count =  PhysicalObject.where(gf => true).where(po_sql_where).size
			gens[PhysicalObject::GENERATION_FIELDS_HUMANIZED[gf]] = count unless count == 0
		end
		gens
	end

	def bases
		b = Hash.new
		PhysicalObject::BASE_FIELDS.each do |bf|
			count = PhysicalObject.where(bf => true).where(po_sql_where).size
			b[PhysicalObject::BASE_FIELDS_HUMANIZED[bf]] = count unless count == 0
		end
		b
	end

	def sounds
		sounds = Hash.new
		PhysicalObject::SOUND_FORMAT_FIELDS.each do |sf|
			count = PhysicalObject.where(sf => true).where(po_sql_where).size
			sounds[PhysicalObject::SOUND_FORMAT_FIELDS_HUMANIZED[sf]] = count unless count == 0
		end
		sounds
	end

	def colors
		colors = Hash.new
		PhysicalObject::COLOR_FIELDS.each do |cf|
			count = PhysicalObject.where(cf => true).where(po_sql_where).size
			colors[PhysicalObject::COLOR_FIELDS_HUMANIZED[cf]] = count unless count == 0
		end
		colors
	end
end
