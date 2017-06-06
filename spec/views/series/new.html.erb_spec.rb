require 'rails_helper'

RSpec.describe "series/new_physical_object", type: :view do
  before(:each) do
    assign(:series, Series.new())
  end

  it "renders new_physical_object series form" do
    render

    assert_select "form[action=?][method=?]", series_index_path, "post" do
    end
  end
end
