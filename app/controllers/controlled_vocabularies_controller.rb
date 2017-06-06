class ControlledVocabulariesController < ApplicationController
  before_action :set_controlled_vocabulary, only: [:show, :edit, :update, :destroy]

  # GET /controlled_vocabularies
  # GET /controlled_vocabularies.json
  def index
    @controlled_vocabularies = ControlledVocabulary.all
  end

  # GET /controlled_vocabularies/1
  # GET /controlled_vocabularies/1.json
  def show
  end

  # GET /controlled_vocabularies/new_physical_object
  def new
    @controlled_vocabulary = ControlledVocabulary.new
  end

  # GET /controlled_vocabularies/1/edit
  def edit
  end

  # POST /controlled_vocabularies
  # POST /controlled_vocabularies.json
  def create
    @controlled_vocabulary = ControlledVocabulary.new(controlled_vocabulary_params)

    respond_to do |format|
      if @controlled_vocabulary.save
        format.html { redirect_to @controlled_vocabulary, notice: 'Controlled vocabulary was successfully created.' }
        format.json { render :show, status: :created, location: @controlled_vocabulary }
      else
        format.html { render :new_physical_object }
        format.json { render json: @controlled_vocabulary.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /controlled_vocabularies/1
  # PATCH/PUT /controlled_vocabularies/1.json
  def update
    respond_to do |format|
      if @controlled_vocabulary.update(controlled_vocabulary_params)
        format.html { redirect_to @controlled_vocabulary, notice: 'Controlled vocabulary was successfully updated.' }
        format.json { render :show, status: :ok, location: @controlled_vocabulary }
      else
        format.html { render :edit }
        format.json { render json: @controlled_vocabulary.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /controlled_vocabularies/1
  # DELETE /controlled_vocabularies/1.json
  def destroy
    @controlled_vocabulary.destroy
    respond_to do |format|
      format.html { redirect_to controlled_vocabularies_url, notice: 'Controlled vocabulary was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_controlled_vocabulary
      @controlled_vocabulary = ControlledVocabulary.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def controlled_vocabulary_params
      params.fetch(:controlled_vocabulary, {})
    end
end
