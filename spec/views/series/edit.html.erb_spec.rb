require 'rails_helper'

RSpec.describe "series/edit", type: :view do
  before(:each) do
    @series = assign(:series, Series.create!())
  end

  it "renders the edit series form" do
    render

    assert_select "form[action=?][method=?]", series_path(@series), "post" do
    end
  end
end
