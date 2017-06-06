require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the CagesHelper. For example:
#
# describe CagesHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe PhysicalObjectsController, type: :controller do

	render_views
	before(:each) { sign_in; request.env['HTTP_REFERER'] = 'source_page' }

	describe "GET index" do

		it "assigns @physical_objects" do
			po = create(:physical_object)
			get :index
			expect(assigns(:physical_objects)).to eq([po])
		end
		it "responds successfully" do
			expect(response.status).to eq(200)
		end

	end

	describe "GET show" do
		it "assigns @physical_object" do
			po = create(:physical_object)
			get :show, {id: po.id}
			expect(assigns(:physical_object)).to eq(po)
		end
		it "responds successfully" do
			expect(response.status).to eq(200)
		end
	end

	describe "GET new" do
		it "assigns @physical_object" do
			get :new
			expect(assigns(:physical_object)).to_not be_nil
		end

	end

	describe "GET edit" do
		it "assigns @physical_object" do
			po = create(:physical_object)
			get :edit, {id: po.id}
			expect(assigns(:physical_object)).to eq(po)
		end
		it "responds successfully" do
			expect(response.status).to eq(200)
		end
	end

	describe "POST create" do
		let(:title) { create(:title, title_text: "Some New Title") }
		it "creates a valid physical object" do
			title
			po = build(:physical_object)
			post :create,  { iu_barcode: po.iu_barcode, unit_id: po.unit_id, inventoried_by: po.inventoried_by, moidified_by: po.modified_by, media_type: po.media_type, medium: po.medium, title_ids: [title.id] }
			expect().to change(PhyscalObject, :count).by(1)
		end
	end

	describe "PATCH/PUT update" do

	end

	describe "GET duplicate" do

	end

	describe "POST create_duplicate" do

	end

	describe "GET edit_ad_strip" do

	end

	describe "POST update_ad_strip" do

	end

	describe "DELETE desctroy" do

	end

end