require "rails_helper"

RSpec.describe CollectionsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/collections").to route_to("collections#index")
    end

    it "routes to #new_physical_object" do
      expect(:get => "/collections/new_physical_object").to route_to("collections#new_physical_object")
    end

    it "routes to #show" do
      expect(:get => "/collections/1").to route_to("collections#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/collections/1/edit").to route_to("collections#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/collections").to route_to("collections#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/collections/1").to route_to("collections#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/collections/1").to route_to("collections#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/collections/1").to route_to("collections#destroy", :id => "1")
    end

  end
end
