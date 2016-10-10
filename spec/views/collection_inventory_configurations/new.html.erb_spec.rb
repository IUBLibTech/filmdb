require 'rails_helper'

RSpec.describe "collection_inventory_configurations/new", type: :view do
  before(:each) do
    assign(:collection_inventory_configuration, CollectionInventoryConfiguration.new())
  end

  it "renders new collection_inventory_configuration form" do
    render

    assert_select "form[action=?][method=?]", collection_inventory_configurations_path, "post" do
    end
  end
end
