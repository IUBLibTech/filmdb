require 'rails_helper'

RSpec.describe "ComponentGroups", type: :request do
  describe "GET /component_groups" do
    it "works! (now write some real specs)" do
      get component_groups_path
      expect(response).to have_http_status(200)
    end
  end
end
