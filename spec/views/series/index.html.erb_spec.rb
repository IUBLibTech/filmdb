require 'rails_helper'

RSpec.describe "series/index", type: :view do
  before(:each) do
    assign(:series, [
      Series.create!(),
      Series.create!()
    ])
  end

  it "renders a list of series" do
    render
  end
end
