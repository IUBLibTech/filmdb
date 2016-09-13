require 'rails_helper'

RSpec.describe "series_titles/edit", type: :view do
  before(:each) do
    @series_title = assign(:series_title, SeriesTitle.create!())
  end

  it "renders the edit series_title form" do
    render

    assert_select "form[action=?][method=?]", series_title_path(@series_title), "post" do
    end
  end
end
