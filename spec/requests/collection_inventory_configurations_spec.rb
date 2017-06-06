require 'rails_helper'

RSpec.describe "CollectionInventoryConfigurations", type: :request do
  describe "GET /collection_inventory_configurations" do
    it "works! (now write some real specs)" do
      get collection_inventory_configurations_path
      expect(response).to have_http_status(200)
    end
  end
end
