require 'rails_helper'

RSpec.describe "component_groups/edit", type: :view do
  before(:each) do
    @component_group = assign(:component_group, ComponentGroup.create!())
  end

  it "renders the edit component_group form" do
    render

    assert_select "form[action=?][method=?]", component_group_path(@component_group), "post" do
    end
  end
end
