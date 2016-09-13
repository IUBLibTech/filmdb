require 'rails_helper'

RSpec.describe "series_titles/new", type: :view do
  before(:each) do
    assign(:series_title, SeriesTitle.new())
  end

  it "renders new series_title form" do
    render

    assert_select "form[action=?][method=?]", series_titles_path, "post" do
    end
  end
end
