require 'rails_helper'

RSpec.describe "SeriesTitles", type: :request do
  describe "GET /series_titles" do
    it "works! (now write some real specs)" do
      get series_titles_path
      expect(response).to have_http_status(200)
    end
  end
end
