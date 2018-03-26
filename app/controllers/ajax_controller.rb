class AjaxController < ApplicationController

  def title_physical_objects
    @title = Title.find(params[:id])
    render json: @title.physical_objects
  end

end
