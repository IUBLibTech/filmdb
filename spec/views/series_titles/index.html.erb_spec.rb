require 'rails_helper'

RSpec.describe "series_titles/index", type: :view do
  before(:each) do
    assign(:series_titles, [
      SeriesTitle.create!(),
      SeriesTitle.create!()
    ])
  end

  it "renders a list of series_titles" do
    render
  end
end
