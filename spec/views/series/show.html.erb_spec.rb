require 'rails_helper'

RSpec.describe "series/show", type: :view do
  before(:each) do
    @series = assign(:series, Series.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
