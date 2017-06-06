require 'rails_helper'

RSpec.describe "Cages", type: :request do
  describe "GET /cages" do
    it "works! (now write some real specs)" do
      get cages_path
      expect(response).to have_http_status(200)
    end
  end
end
