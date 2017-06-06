require 'rails_helper'

RSpec.describe "controlled_vocabularies/show", type: :view do
  before(:each) do
    @controlled_vocabulary = assign(:controlled_vocabulary, ControlledVocabulary.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
