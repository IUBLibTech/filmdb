require 'rails_helper'

RSpec.describe "cages/new", type: :view do
  before(:each) do
    assign(:cage, Cage.new())
  end

  it "renders new cage form" do
    render

    assert_select "form[action=?][method=?]", cages_path, "post" do
    end
  end
end
