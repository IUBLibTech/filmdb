class SpreadsheetsController < ApplicationController
  before_action :set_spreadsheet, only: [:show, :edit, :update, :destroy]

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
    @titles = Title.where(spreadsheet_id: @spreadsheet.id)
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
          SpreadsheetsHelper.parse_serial(@file, ss, sss)
          format.html { redirect_to spreadsheets_path, notice: "#{@file.original_filename} has been submitted. Please refresh the page to monitor progress." }
        end
      end
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
