require 'rails_helper'

RSpec.describe "Series", type: :request do
  describe "GET /series" do
    it "works! (now write some real specs)" do
      get series_index_path
      expect(response).to have_http_status(200)
    end
  end
end
