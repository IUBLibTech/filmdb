require 'rails_helper'

RSpec.describe "collections/new_physical_object", type: :view do
  before(:each) do
    assign(:collection, Collection.new())
  end

  it "renders new_physical_object collection form" do
    render

    assert_select "form[action=?][method=?]", collections_path, "post" do
    end
  end
end
