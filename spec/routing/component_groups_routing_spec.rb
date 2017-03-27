require "rails_helper"

RSpec.describe ComponentGroupsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/component_groups").to route_to("component_groups#index")
    end

    it "routes to #new" do
      expect(:get => "/component_groups/new").to route_to("component_groups#new")
    end

    it "routes to #show" do
      expect(:get => "/component_groups/1").to route_to("component_groups#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/component_groups/1/edit").to route_to("component_groups#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/component_groups").to route_to("component_groups#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/component_groups/1").to route_to("component_groups#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/component_groups/1").to route_to("component_groups#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/component_groups/1").to route_to("component_groups#destroy", :id => "1")
    end

  end
end
