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
  end

  # DELETE /spreadsheets/1
  # DELETE /spreadsheets/1.json
  def destroy
    @spreadsheet.physical_objects.destroy_all
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
        if ss
          format.html { redirect_to spreadsheets_path, notice: "#{@file.original_filename} has already been uploaded" }
        else
          SpreadsheetsHelper.parse_spreadsheet(@file)
          format.html { redirect_to spreadsheets_path, notice: "#{@file.original_filename} has been successfully uploaded." }
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
