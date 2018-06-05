class ControlledVocabulariesController < ApplicationController
  before_action :set_controlled_vocabulary, only: [:show, :edit, :update, :destroy]

  # GET /controlled_vocabularies
  # GET /controlled_vocabularies.json
  def index
    authorize ControlledVocabulary
    @cv = ControlledVocabulary.new
  end

end
