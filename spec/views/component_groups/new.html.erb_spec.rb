require 'rails_helper'

RSpec.describe "component_groups/new", type: :view do
  before(:each) do
    assign(:component_group, ComponentGroup.new())
  end

  it "renders new component_group form" do
    render

    assert_select "form[action=?][method=?]", component_groups_path, "post" do
    end
  end
end
