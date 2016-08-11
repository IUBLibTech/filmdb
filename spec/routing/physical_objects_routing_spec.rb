describe PhysicalObjectsController, type: :routing do
	describe "routing" do
		it "routes to #index" do
			expect(get("/physical_objects/")).to be_routable
		end
		it "routes to #new" do
			expect(get("/physical_objects/new")).to be_routable
		end
		it "routes to #create" do
			expect(post("/physical_objects/")).to be_routable
		end
		it "routes to #edit" do
			expect(get("/physical_objects/1/edit")).to be_routable
		end
		it "routes to #update" do
			expect(patch("/physical_objects/1")).to be_routable
		end
		it "routes to #destroy" do
			expect(delete("/physical_objects/1")).to be_routable
		end
	end
end