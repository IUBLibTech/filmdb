require 'rails_helper'

RSpec.describe "controlled_vocabularies/new_physical_object", type: :view do
  before(:each) do
    assign(:controlled_vocabulary, ControlledVocabulary.new())
  end

  it "renders new_physical_object controlled_vocabulary form" do
    render

    assert_select "form[action=?][method=?]", controlled_vocabularies_path, "post" do
    end
  end
end
