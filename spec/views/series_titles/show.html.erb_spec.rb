require 'rails_helper'

RSpec.describe "series_titles/show", type: :view do
  before(:each) do
    @series_title = assign(:series_title, SeriesTitle.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
