class SpreadsheetsController < ApplicationController
  require 'csv_parser'
  before_action :set_spreadsheet, only: [:show, :edit, :update, :destroy, :merge_candidates]

  # GET /spreadsheets
  # GET /spreadsheets.json
  def index
    @spreadsheets = Spreadsheet.all
    @file = ""
  end

  # GET /spreadsheets/1
  # GET /spreadsheets/1.json
  def show
    @physical_objects = @spreadsheet.physical_objects
    @users = User.where(created_in_spreadsheet: @spreadsheet.id)
    @title_count = Title.where(spreadsheet_id: @spreadsheet.id).group('title_text').count
    @other_title_count = Title.where('(spreadsheet_id IS NULL or spreadsheet_id != ?) ', @spreadsheet.id).group('title_text').count
  end

  # DELETE /spreadsheets/1
  # DELETE /spreadsheets/1.json
  def destroy
    @spreadsheet.physical_objects.destroy_all
    @spreadsheet.titles.destroy_all
    @spreadsheet.series.destroy_all
    @spreadsheet.created_users.destroy_all
    @spreadsheet.destroy

    respond_to do |format|
      format.html { redirect_to spreadsheets_url, notice: 'Spreadsheet was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # POST /spreadsheets/upload
  def upload
    @file = params[:xls_file]
    respond_to do |format|
      if @file.blank?
        format.html { redirect_to spreadsheets_path, notice: 'You must specify an inventory file.'}
      else
        # check filename
        ss = Spreadsheet.where(filename: @file.original_filename).first
        if !ss.nil? and ss.successful_upload
          format.html { redirect_to spreadsheets_path, notice: "#{@file.original_filename} has already been uploaded successfully" }
        else
          if ss.nil?
            ss = Spreadsheet.new(filename: @file.original_filename)
            ss.save
          end
          sss = SpreadsheetSubmission.new(spreadsheet_id: ss.id)
          sss.save
          parser = CsvParser.new(@file, ss, sss)
          parser.parse_csv
          format.html { redirect_to spreadsheets_path, notice: "#{@file.original_filename} has been submitted. Please refresh the page to monitor progress." }
        end
      end
    end
  end

  # action which lists matching titles (by title text) for a given spreadsheet id
  def merge_candidates
    @title_candidates = Title.titles_in_spreadsheet(params[:title], @spreadsheet.id)
    @existing_titles = Title.title_count_not_in_spreadsheet(params[:title], @spreadsheet.id)
  end

  # processes the form submission fomr #merge_conditate view
  def merge_titles
    respond_to do |format|
      @master_title = Title.find(params[:master])
      @mergees = Title.where(id: params[:selected].split(','))
      @mergees.each do |m|
        if @master_title.series_part.blank?
          @master_title.series_part = m.series_part
        end
        unless m.summary.blank?
          @master_title.summary += " | #{m.summary}"
        end

        m.title_original_identifiers.each do |toi|
          unless @master_title.title_original_identifiers.include? toi
            @master_title.title_original_identifiers << toi
          end
        end
        m.title_creators.each do |tc|
          unless @master_title.title_creators.collect.include? tc
            @master_title.title_creators << tc
          end
        end
        m.title_publishers.each do |tp|
          unless @master_title.title_publishers.collect.include? tp
            @master_title.title_publishers << tp
          end
        end
        m.title_forms.each do |tf|
          unless @master_title.title_forms.collect.include? tf
            @master_title.title_forms << tf
          end
        end
        m.title_genres.each do |tg|
          unless @master_title.title_genres.collect.include? tg
            @master_title.title_genres << tg
          end
        end
        m.title_dates.each do |td|
          unless @master_title.title_dates.collect.include? td
            @master_title.title_dates << td
          end
        end
        m.title_locations.each do |tl|
          unless @master_title.title_locations.collect.include? tl
            @master_title.title_locations << tl
          end
        end
        m.physical_objects.each do |po|
          @master_title.physical_objects << po
        end
        m.delete
      end
      @master_title.save
      # renamed so that the renderer of title knows what to render
      @title = @master_title
      format.html { redirect_to @title, notice: "#{@mergees.size} Titles Were Successfully Merged." }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_spreadsheet
      @spreadsheet = Spreadsheet.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def spreadsheet_params
      params.fetch(:spreadsheet, {})
    end
end
