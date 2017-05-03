class StatsController < ApplicationController

	before_action :set_filters

	def index
		@title_count = Title.all.size
		@empty_title_count = Title.includes(:physical_object_titles).where(physical_object_titles: {title_id: nil}).size
		@series_count = Series.all.size
		@empty_series_count = Series.includes(:titles).where(titles: {id: nil}).size
		@physical_object_count = PhysicalObject.all.size
	end

	def filter_index
		#if unit or collection are specified we have to go from physical object to title/series sinces the associtions to unit/collect are through physical object and not title.
	end

	def empty_titles

	end

	def empty_series

	end

	private
	def set_filters
		unless params[:unit].blank? || params[:unit] == 0
			@unit = Unit.find(params[:unit])
		end
		unless params[:collection_id].blank? || params[:collection_id] == 0
			@collection = Collection.find(params[:collection_id])
		end
		unless params[:start].blank? || params[:start] == 0
			@startTime = DateTime.parse(params[:start])
			@endTime = DateTime.parse(params[:end])
		end
	end

	def title_sql
		sql = @unit ? "unit_id = #{@unit.id}" : ""
		sql += @collection ? (sql.length > 0 ? " AND " : "")+"collection_id = #{@collection.id}" : ""
		sql += @startTime ? (sql.length > 0 ? " AND " : "")+"created_at >= #{@startTime} AND created_at <= #{@endTime}" : ""
		sql
	end

	def title_count
		Title.where(sql).size
	end

	def series_count
		Series.where()
	end



end
