class ComponentGroupsController < ApplicationController
  before_action :set_component_group, only: [:show, :edit, :update, :destroy]

  # GET /component_groups
  # GET /component_groups.json
  def index
    @component_groups = ComponentGroup.all
  end

  # GET /component_groups/1
  # GET /component_groups/1.json
  def show
  end

  # GET /component_groups/new
  def new
    @component_group = ComponentGroup.new
  end

  # GET /component_groups/1/edit
  def edit
  end

  # POST /component_groups
  # POST /component_groups.json
  def create
    @component_group = ComponentGroup.new(component_group_params)

    respond_to do |format|
      if @component_group.save
        format.html { redirect_to @component_group, notice: 'Component group was successfully created.' }
        format.json { render :show, status: :created, location: @component_group }
      else
        format.html { render :new }
        format.json { render json: @component_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /component_groups/1
  # PATCH/PUT /component_groups/1.json
  def update
    respond_to do |format|
      if @component_group.update(component_group_params)
        format.html { redirect_to @component_group, notice: 'Component group was successfully updated.' }
        format.json { render :show, status: :ok, location: @component_group }
      else
        format.html { render :edit }
        format.json { render json: @component_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /component_groups/1
  # DELETE /component_groups/1.json
  def destroy
    @component_group.destroy
    respond_to do |format|
      format.html { redirect_to component_groups_url, notice: 'Component group was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_component_group
      @component_group = ComponentGroup.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def component_group_params
      params.fetch(:component_group, {})
    end
end
