class CollectionInventoryConfigurationsController < ApplicationController
  include CollectionInventoryConfigurationsHelper
  before_action :set_collection_inventory_configuration, only: [:show, :edit, :update, :destroy]

  # GET /collection_inventory_configurations
  # GET /collection_inventory_configurations.json
  def index
    @collection_inventory_configurations = CollectionInventoryConfiguration.all
  end

  # GET /collection_inventory_configurations/1
  # GET /collection_inventory_configurations/1.json
  def show
  end

  # GET /collection_inventory_configurations/new_physical_object
  def new
    @collection_inventory_configuration = CollectionInventoryConfigurationsHelper.default_config
  end

  # GET /collection_inventory_configurations/1/edit
  def edit
  end

  # POST /collection_inventory_configurations
  # POST /collection_inventory_configurations.json
  def create
    @collection_inventory_configuration = CollectionInventoryConfiguration.new(collection_inventory_configuration_params)

    respond_to do |format|
      if @collection_inventory_configuration.save
        format.html { redirect_to @collection_inventory_configuration, notice: 'Collection inventory configuration was successfully created.' }
        format.json { render :show, status: :created, location: @collection_inventory_configuration }
      else
        format.html { render :new_physical_object }
        format.json { render json: @collection_inventory_configuration.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /collection_inventory_configurations/1
  # PATCH/PUT /collection_inventory_configurations/1.json
  def update
    respond_to do |format|
      if @collection_inventory_configuration.update(collection_inventory_configuration_params)
        format.html { redirect_to @collection_inventory_configuration, notice: 'Collection inventory configuration was successfully updated.' }
        format.json { render :show, status: :ok, location: @collection_inventory_configuration }
      else
        format.html { render :edit }
        format.json { render json: @collection_inventory_configuration.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /collection_inventory_configurations/1
  # DELETE /collection_inventory_configurations/1.json
  def destroy
    @collection_inventory_configuration.destroy
    respond_to do |format|
      format.html { redirect_to collection_inventory_configurations_url, notice: 'Collection inventory configuration was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_collection_inventory_configuration
      @collection_inventory_configuration = CollectionInventoryConfiguration.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def collection_inventory_configuration_params
      params.require(:collection_inventory_configuration).permit(
          :collection_id, :location, :copy_right, :series_production_number, :series_part, :alternative_title, :title_version,
          :item_original_identifier, :summary, :creator, :distributors, :credits, :language, :accompanying_documentation, :notes,
          :generation, :base, :stock, :access, :gauge, :can_size, :footage, :duration, :reel_number, :format_notes, :picture_type, :frame_rate,
          :color_or_bw, :aspect_ratio, :sound_field_language, :captions_or_subtitles, :silent, :sound_format_type, :sound_content_type,
          :sound_configuration, :ad_strip, :shrinkage, :mold, :condition_type, :condition_rating, :research_value, :conservation_actions
      )
    end
end
