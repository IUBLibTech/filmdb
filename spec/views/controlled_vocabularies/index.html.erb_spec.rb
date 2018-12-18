require 'rails_helper'

RSpec.describe "controlled_vocabularies/index", type: :view do
  before(:each) do
    assign(:controlled_vocabularies, [
      ControlledVocabulary.create!(),
      ControlledVocabulary.create!()
    ])
  end

  it "renders a list of controlled_vocabularies" do
    render
  end
end
