require 'rails_helper'

RSpec.describe "component_groups/index", type: :view do
  before(:each) do
    assign(:component_groups, [
      ComponentGroup.create!(),
      ComponentGroup.create!()
    ])
  end

  it "renders a list of component_groups" do
    render
  end
end
