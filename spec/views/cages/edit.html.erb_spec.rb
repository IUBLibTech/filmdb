require 'rails_helper'

RSpec.describe "cages/edit", type: :view do
  before(:each) do
    @cage = assign(:cage, Cage.create!())
  end

  it "renders the edit cage form" do
    render

    assert_select "form[action=?][method=?]", cage_path(@cage), "post" do
    end
  end
end
