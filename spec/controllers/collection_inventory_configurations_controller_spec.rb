require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe CollectionInventoryConfigurationsController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # CollectionInventoryConfiguration. As you add validations to CollectionInventoryConfiguration, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # CollectionInventoryConfigurationsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all collection_inventory_configurations as @collection_inventory_configurations" do
      collection_inventory_configuration = CollectionInventoryConfiguration.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:collection_inventory_configurations)).to eq([collection_inventory_configuration])
    end
  end

  describe "GET #show" do
    it "assigns the requested collection_inventory_configuration as @collection_inventory_configuration" do
      collection_inventory_configuration = CollectionInventoryConfiguration.create! valid_attributes
      get :show, {:id => collection_inventory_configuration.to_param}, valid_session
      expect(assigns(:collection_inventory_configuration)).to eq(collection_inventory_configuration)
    end
  end

  describe "GET #new_physical_object" do
    it "assigns a new_physical_object collection_inventory_configuration as @collection_inventory_configuration" do
      get :new_physical_object, {}, valid_session
      expect(assigns(:collection_inventory_configuration)).to be_a_new(CollectionInventoryConfiguration)
    end
  end

  describe "GET #edit" do
    it "assigns the requested collection_inventory_configuration as @collection_inventory_configuration" do
      collection_inventory_configuration = CollectionInventoryConfiguration.create! valid_attributes
      get :edit, {:id => collection_inventory_configuration.to_param}, valid_session
      expect(assigns(:collection_inventory_configuration)).to eq(collection_inventory_configuration)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new_physical_object CollectionInventoryConfiguration" do
        expect {
          post :create, {:collection_inventory_configuration => valid_attributes}, valid_session
        }.to change(CollectionInventoryConfiguration, :count).by(1)
      end

      it "assigns a newly created collection_inventory_configuration as @collection_inventory_configuration" do
        post :create, {:collection_inventory_configuration => valid_attributes}, valid_session
        expect(assigns(:collection_inventory_configuration)).to be_a(CollectionInventoryConfiguration)
        expect(assigns(:collection_inventory_configuration)).to be_persisted
      end

      it "redirects to the created collection_inventory_configuration" do
        post :create, {:collection_inventory_configuration => valid_attributes}, valid_session
        expect(response).to redirect_to(CollectionInventoryConfiguration.last)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved collection_inventory_configuration as @collection_inventory_configuration" do
        post :create, {:collection_inventory_configuration => invalid_attributes}, valid_session
        expect(assigns(:collection_inventory_configuration)).to be_a_new(CollectionInventoryConfiguration)
      end

      it "re-renders the 'new_physical_object' template" do
        post :create, {:collection_inventory_configuration => invalid_attributes}, valid_session
        expect(response).to render_template("new_physical_object")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested collection_inventory_configuration" do
        collection_inventory_configuration = CollectionInventoryConfiguration.create! valid_attributes
        put :update, {:id => collection_inventory_configuration.to_param, :collection_inventory_configuration => new_attributes}, valid_session
        collection_inventory_configuration.reload
        skip("Add assertions for updated state")
      end

      it "assigns the requested collection_inventory_configuration as @collection_inventory_configuration" do
        collection_inventory_configuration = CollectionInventoryConfiguration.create! valid_attributes
        put :update, {:id => collection_inventory_configuration.to_param, :collection_inventory_configuration => valid_attributes}, valid_session
        expect(assigns(:collection_inventory_configuration)).to eq(collection_inventory_configuration)
      end

      it "redirects to the collection_inventory_configuration" do
        collection_inventory_configuration = CollectionInventoryConfiguration.create! valid_attributes
        put :update, {:id => collection_inventory_configuration.to_param, :collection_inventory_configuration => valid_attributes}, valid_session
        expect(response).to redirect_to(collection_inventory_configuration)
      end
    end

    context "with invalid params" do
      it "assigns the collection_inventory_configuration as @collection_inventory_configuration" do
        collection_inventory_configuration = CollectionInventoryConfiguration.create! valid_attributes
        put :update, {:id => collection_inventory_configuration.to_param, :collection_inventory_configuration => invalid_attributes}, valid_session
        expect(assigns(:collection_inventory_configuration)).to eq(collection_inventory_configuration)
      end

      it "re-renders the 'edit' template" do
        collection_inventory_configuration = CollectionInventoryConfiguration.create! valid_attributes
        put :update, {:id => collection_inventory_configuration.to_param, :collection_inventory_configuration => invalid_attributes}, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested collection_inventory_configuration" do
      collection_inventory_configuration = CollectionInventoryConfiguration.create! valid_attributes
      expect {
        delete :destroy, {:id => collection_inventory_configuration.to_param}, valid_session
      }.to change(CollectionInventoryConfiguration, :count).by(-1)
    end

    it "redirects to the collection_inventory_configurations list" do
      collection_inventory_configuration = CollectionInventoryConfiguration.create! valid_attributes
      delete :destroy, {:id => collection_inventory_configuration.to_param}, valid_session
      expect(response).to redirect_to(collection_inventory_configurations_url)
    end
  end

end
