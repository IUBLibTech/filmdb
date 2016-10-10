require "rails_helper"

RSpec.describe CollectionInventoryConfigurationsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/collection_inventory_configurations").to route_to("collection_inventory_configurations#index")
    end

    it "routes to #new" do
      expect(:get => "/collection_inventory_configurations/new").to route_to("collection_inventory_configurations#new")
    end

    it "routes to #show" do
      expect(:get => "/collection_inventory_configurations/1").to route_to("collection_inventory_configurations#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/collection_inventory_configurations/1/edit").to route_to("collection_inventory_configurations#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/collection_inventory_configurations").to route_to("collection_inventory_configurations#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/collection_inventory_configurations/1").to route_to("collection_inventory_configurations#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/collection_inventory_configurations/1").to route_to("collection_inventory_configurations#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/collection_inventory_configurations/1").to route_to("collection_inventory_configurations#destroy", :id => "1")
    end

  end
end
