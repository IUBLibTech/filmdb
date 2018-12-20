require 'rails_helper'

RSpec.describe "component_groups/show", type: :view do
  before(:each) do
    @component_group = assign(:component_group, ComponentGroup.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
