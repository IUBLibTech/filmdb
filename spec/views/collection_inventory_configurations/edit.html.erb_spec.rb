require 'rails_helper'

RSpec.describe "collection_inventory_configurations/edit", type: :view do
  before(:each) do
    @collection_inventory_configuration = assign(:collection_inventory_configuration, CollectionInventoryConfiguration.create!())
  end

  it "renders the edit collection_inventory_configuration form" do
    render

    assert_select "form[action=?][method=?]", collection_inventory_configuration_path(@collection_inventory_configuration), "post" do
    end
  end
end
