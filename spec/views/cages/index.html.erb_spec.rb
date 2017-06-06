require 'rails_helper'

RSpec.describe "cages/index", type: :view do
  before(:each) do
    assign(:cages, [
      Cage.create!(),
      Cage.create!()
    ])
  end

  it "renders a list of cages" do
    render
  end
end
