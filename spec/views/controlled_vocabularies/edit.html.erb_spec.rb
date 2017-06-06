require 'rails_helper'

RSpec.describe "controlled_vocabularies/edit", type: :view do
  before(:each) do
    @controlled_vocabulary = assign(:controlled_vocabulary, ControlledVocabulary.create!())
  end

  it "renders the edit controlled_vocabulary form" do
    render

    assert_select "form[action=?][method=?]", controlled_vocabulary_path(@controlled_vocabulary), "post" do
    end
  end
end
