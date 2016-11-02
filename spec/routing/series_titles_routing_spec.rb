require "rails_helper"

RSpec.describe SeriesTitlesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/series_titles").to route_to("series_titles#index")
    end

    it "routes to #new_physical_object" do
      expect(:get => "/series_titles/new_physical_object").to route_to("series_titles#new_physical_object")
    end

    it "routes to #show" do
      expect(:get => "/series_titles/1").to route_to("series_titles#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/series_titles/1/edit").to route_to("series_titles#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/series_titles").to route_to("series_titles#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/series_titles/1").to route_to("series_titles#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/series_titles/1").to route_to("series_titles#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/series_titles/1").to route_to("series_titles#destroy", :id => "1")
    end

  end
end
