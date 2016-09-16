class SeriesTitlesController < ApplicationController
  before_action :set_series_title, only: [:show, :edit, :update, :destroy]

  # GET /series_titles
  # GET /series_titles.json
  def index
    @series_titles = SeriesTitle.all
  end

  # GET /series_titles/1
  # GET /series_titles/1.json
  def show
  end

  # GET /series_titles/new
  def new
    @series_title = SeriesTitle.new
  end

  # GET /series_titles/1/edit
  def edit
  end

  # POST /series_titles
  # POST /series_titles.json
  def create
    @series_title = SeriesTitle.new(series_title_params)

    respond_to do |format|
      if @series_title.save
        format.html { redirect_to @series_title, notice: 'Series title was successfully created.' }
        format.json { render :show, status: :created, location: @series_title }
      else
        format.html { render :new }
        format.json { render json: @series_title.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /series_titles/1
  # PATCH/PUT /series_titles/1.json
  def update
    respond_to do |format|
      if @series_title.update(series_title_params)
        format.html { redirect_to @series_title, notice: 'Series title was successfully updated.' }
        format.json { render :show, status: :ok, location: @series_title }
      else
        format.html { render :edit }
        format.json { render json: @series_title.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /series_titles/1
  # DELETE /series_titles/1.json
  def destroy
    @series_title.destroy
    respond_to do |format|
      format.html { redirect_to series_titles_url, notice: 'Series title was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_series_title
      @series_title = SeriesTitle.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def series_title_params
      params.require(:series_title).permit(:series_title, :description)
    end
end
