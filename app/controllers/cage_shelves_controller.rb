class CageShelvesController < ApplicationController
  def index
    @cage_shelves = CageShelf.joins(:physical_objects).group('cage_shelves.id').order('id DESC')
  end

  def show
    @cage_shelf = CageShelf.includes(:physical_objects).find(params[:id])
  end

end
