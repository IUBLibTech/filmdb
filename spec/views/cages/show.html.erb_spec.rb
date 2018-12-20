require 'rails_helper'

RSpec.describe "cages/show", type: :view do
  before(:each) do
    @cage = assign(:cage, Cage.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
