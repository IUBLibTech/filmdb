class CageShelvesController < ApplicationController
  require 'memnon_digiprov_collector'

  def index
    @cage_shelves = CageShelf.joins(:physical_objects).group('cage_shelves.id').order('id DESC')
  end

  def show
    @cage_shelf = CageShelf.includes(:physical_objects).find(params[:id])
  end

  def get_digiprov
    @cage_shelf = CageShelf.find(params[:id])
    MemnonDigiprovCollector.new.collect_shelf_in_thread(params[:id])
    flash.now[:notice] = "A request has been started to collect digital statuses and digital provenance for "+
        "#{@cage_shelf.identifier}. Depending on the number of physical objects in the cage shelf, this may take awhile."
    render :show
  end

end
