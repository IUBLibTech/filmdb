require 'rails_helper'

RSpec.describe "titles/new_physical_object", type: :view do
  before(:each) do
    assign(:title, Title.new())
  end

  it "renders new_physical_object title form" do
    render

    assert_select "form[action=?][method=?]", titles_path, "post" do
    end
  end
end
