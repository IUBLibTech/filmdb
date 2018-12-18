require 'rails_helper'

RSpec.describe "collection_inventory_configurations/index", type: :view do
  before(:each) do
    assign(:collection_inventory_configurations, [
      CollectionInventoryConfiguration.create!(),
      CollectionInventoryConfiguration.create!()
    ])
  end

  it "renders a list of collection_inventory_configurations" do
    render
  end
end
