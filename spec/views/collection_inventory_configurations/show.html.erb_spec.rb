require 'rails_helper'

RSpec.describe "collection_inventory_configurations/show", type: :view do
  before(:each) do
    @collection_inventory_configuration = assign(:collection_inventory_configuration, CollectionInventoryConfiguration.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
