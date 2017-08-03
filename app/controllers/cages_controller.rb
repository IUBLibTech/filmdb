class CagesController < ApplicationController
	include CagesHelper
	include ServicesHelper
	require 'manual_roll_back_error'

	before_action :set_cages, only: [:index, :mark_shipped]
  before_action :set_cage, only: [:show, :edit, :update, :destroy, :show_xml, :mark_ready_to_ship, :unmark_ready_to_ship, :mark_shipped]

	before_action :set_cage_shelf, only: [:shelf_physical_objects, :add_physical_object_to_shelf, :remove_physical_object]


  # GET /cages/1
  # GET /cages/1.json
  def show
		respond_to do |format|
			format.html
		end
  end

  # GET /cages/new
  def new
	  max = Cage.maximum('id')
    @cage = Cage.new(identifier: "Cage #{max.nil? ? 1 : max + 1}")
	  @cage.top_shelf.identifier = "TS_#{max.nil? ? 1 : max + 1}"
	  @cage.middle_shelf.identifier ="MS_#{max.nil? ? 1 : max + 1}"
	  @cage.bottom_shelf.identifier = "BS_#{max.nil? ? 1 : max + 1}"
  end

  # POST /cages
  # POST /cages.json
  def create
    @cage = Cage.new(cage_params)
    respond_to do |format|
      if @cage.save
				# FIXME: not able to figure out how to set the bi-directional associations in Cage.initialize
				@cage.top_shelf.update_attributes(cage_id: @cage.id)
				@cage.middle_shelf.update_attributes(cage_id: @cage.id)
				@cage.bottom_shelf.update_attributes(cage_id: @cage.id)
        format.html { redirect_to @cage, notice: 'Cage was successfully created.' }
        format.json { render :show, status: :created, location: @cage }
      else
        format.html { render :new }
        format.json { render json: @cage.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cages/1
  # PATCH/PUT /cages/1.json
  def update
    respond_to do |format|
      if @cage.update(cage_params)
        format.html { redirect_to @cage, notice: 'Cage was successfully updated.' }
        format.json { render :show, status: :ok, location: @cage }
      else
        format.html { render :edit }
        format.json { render json: @cage.errors, status: :unprocessable_entity }
      end
    end
	end

	def mark_ready_to_ship
		if @cage.can_by_shipped?
			@cage.update_attributes(ready_to_ship: true)
			flash[:notice] = "Cage #{@cage.identifier} is ready to ship to Memnon"
			redirect_to :cages
		else
			flash.now[:warning] = "Cage #{@cage.identifier} cannot be marked ready to ship. It either contains 0 physical objects, or 1 or more shelves with physical objects does not have an MDPI barcode assigned."
			render :show
		end
	end

	def unmark_ready_to_ship
		if @cage.ready_to_ship
			@cage.update_attributes(ready_to_ship: false)
			flash[:notice] = "#{@cage.identifier} was changed to 'Not Ready to Ship'"
		else
			flash[:warning] = "#{@cage.identifier} was not marked 'Ready to Ship' - not change made to database."
		end
		redirect_to :cages
	end

	def mark_shipped
		if @cage.ready_to_ship
			begin
				PhysicalObject.transaction do
					@cage.update_attributes(shipped: true)
					flash.now[:notice] = "#{@cage.identifier} was shipped to Memnon"
					@cage.top_shelf.physical_objects.each do |p|
						p.workflow_statuses << WorkflowStatus.build_workflow_status(WorkflowStatus::SHIPPED_EXTERNALLY, p)
						p.save!
					end
					@cage.middle_shelf.physical_objects.each do |p|
						p.workflow_statuses << WorkflowStatus.build_workflow_status(WorkflowStatus::SHIPPED_EXTERNALLY, p)
						p.save!
					end
					@cage.bottom_shelf.physical_objects.each do |p|
						p.workflow_statuses << WorkflowStatus.build_workflow_status(WorkflowStatus::SHIPPED_EXTERNALLY, p)
						p.save!
					end
					@result = push_cage_to_pod(@cage)
					body = @result.body
					unless body == 'SUCCESS'
						@msg = "POD did not receive the push correctly - Responded with message<br/><pre>#{body}</pre>".html_safe
						raise ManualRollBackError, @msg
					end
				end
			rescue ManualRollBackError => e
				flash.now[:warning] = @msg
			ensure
				PodPush.new(cage_id: @cage.id, response: @result.body).save
			end
		else
			flash.now[:warning] = "#{@cage.identifier} could not be shipped to Memnon - it is not ready."
		end
		redirect_to '/cages'
	end

	def shelf_physical_objects
		render partial: 'cage_shelf_physical_objects'
	end

  def add_physical_object_to_shelf
		bc = params[:cage][:physical_object_iu_barcode]
		@physical_object =  PhysicalObject.where(iu_barcode: bc).first
		if @physical_object.nil?
			@physical_object = PhysicalObject.new
			@physical_object.errors.add(:iu_barcode, "Could not find record with IU Barcode #{bc}")
		elsif !@physical_object.cage_shelf.nil?
			@physical_object.errors.add(:cage_shelf, "#{bc} has already been added to Cage #{@physical_object.cage_shelf.cage.identifier}")
		else
			# need to check validity of both barcodes
			mbc = params[:cage][:physical_object_mdpi_barcode]
			if mbc.blank?
				@physical_object.errors.add(:mdpi_barcode, "Cannot pack a physical object without an MDPI barcode")
			elsif !ApplicationHelper.valid_barcode?(mbc, true)
				@physical_object.errors.add(:mdpi_barcode, "#{mbc} is not a valid MDPI barcode")
			elsif CageShelf.where(mdpi_barcode: mbc.to_i).size > 0
				@physical_object.errors.add(:mdpi_barcode, "MDPI barcode #{mbc} has already beed assigned to a cage shelf!")
			elsif !@physical_object.mdpi_barcode.nil? && @physical_object.mdpi_barcode != mbc.to_i
				@physical_object.errors.add(:mdpi_barcode, "#{@physical_object.iu_barcode} has already been assigned an MDPI barcode: #{@physical_object.mdpi_barcode}")
			elsif !@physical_object.current_workflow_status.valid_next_workflow?(WorkflowStatus::IN_CAGE)
				@physical_object.errors.add(:current_workflow_status, "prevents packing this Physical Object: #{@physical_object.current_workflow_status.type_and_location}")
			else
				PhysicalObject.transaction do
					@physical_object.mdpi_barcode = mbc.to_i if @physical_object.mdpi_barcode.nil?
					@physical_object.cage_shelf_id = @cage_shelf.id
					ws = WorkflowStatus.build_workflow_status(WorkflowStatus::IN_CAGE, @physical_object)
					@physical_object.workflow_statuses << ws
					@physical_object.save
				end
			end
		end
		if @physical_object.errors.any?
      render partial: 'ajax_add_po_failure'
		else
			@msg = "Physical Object #{@physical_object.mdpi_barcode} was successfully added to Shelf #{@physical_object.cage_shelf.identifier}"
			list = @physical_object.waiting_active_component_group_members?
			if list && list.size > 0
				@msg += "<br/>Additional Reels for this title: #{ list.collect{ |p| p.iu_barcode }.join(', ') }".html_safe
			end
      render partial: 'ajax_add_po_success'
		end
  end

	def push_result
		@cage = Cage.find(params[:id])
	end

	def remove_physical_object
		# don't add this call to before_action :set_physical_object - the PO is determined by different passed params (mdpi_barcode vs po.id)
		@physical_object = PhysicalObject.find(params[:po_id])
		if @physical_object.cage_shelf != @cage_shelf
			@msg = "Physical Object #{params[:barcode]} is not contained in this Shelf"
			render partial: 'ajax_add_po_failure'
		else
			@msg = "Physical Object #{@physical_object.mdpi_barcode} successfully removed from Shelf #{@cage_shelf.identifier}"
			@physical_object.cage_shelf = nil
			ws = WorkflowStatus.build_workflow_status(WorkflowStatus::TWO_K_FOUR_K_SHELVES, @physical_object)
			@physical_object.workflow_statuses << ws
			@physical_object.save
			@cage_shelf.reload
			render partial: 'ajax_add_po_success'
		end
	end

  # DELETE /cages/1
  # DELETE /cages/1.json
  def destroy
	  authorize Cage
    @cage.destroy
    respond_to do |format|
      format.html { redirect_to cages_url, notice: 'Cage was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

	def show_xml
		file_path = write_xml(@cage)
		render file: file_path, layout: false, status: 200
	end

  private
	# Use callbacks to share common setup or constraints between actions.
	def set_cage
		@cage = Cage.find(params[:id])
	end

	def set_cages
		@cages = Cage.all.order('updated_at DESC')
	end

	def set_cage_shelf
		@cage_shelf = CageShelf.find(params[:id])
	end

	def set_physical_object
		@physical_object = PhysicalObject.where(iu_barcode: params[:barcode]).first
	end

	# Never trust parameters from the scary internet, only allow the white list through.
	def cage_params
		params.require(:cage).permit(:identifier, :notes,
			 #top_shelf: [:id, :identifier, :mdpi_barcode, :notes, :_destroy],
			 #middle_shelf: [:id, :identifier, :mdpi_barcode, :notes, :_destroy],
			 #bottom_shelf: [:id, :identifier, :mdpi_barcode, :notes,:_destroy],
			 top_shelf_attributes: [:id, :identifier, :mdpi_barcode, :notes, :_destroy],
			 middle_shelf_attributes: [:id, :identifier, :mdpi_barcode, :notes, :_destroy],
			 bottom_shelf_attributes: [:id, :identifier, :mdpi_barcode, :notes, :_destroy]
		)
	end
end
