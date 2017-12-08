class TitlesController < ApplicationController
  include PhysicalObjectsHelper
  include TitlesHelper
  before_action :set_title, only: [:show, :edit, :update, :destroy, :create_physical_object, :new_physical_object, :ajax_summary, :create_component_group]
  before_action :set_series, only: [:create, :create_ajax, :update]
  before_action :set_physical_object_cv, only:[:create_physical_object, :new_physical_object]
  before_action :set_all_title_cv, only: [:new, :edit, :new_ajax]


  # def old_index
  #   if params[:selected] && params[:selected] == 'true'
  #     @titles = Title.titles_selected_for_digitization
  #   else
  #     @titles = Title.titles_not_selected_for_digitization
  #   end
  # end

  def search
	  if params[:title_text]
		  # find out whether or not to do pagination
		  @count = Title.title_search_count(params[:title_text], params[:date], params[:publisher_text], params[:creator_text],
		                               (params[:collection_id] == '0' ? nil : params[:collection_id]), current_user, 0, Title.all.size)
		  if @count > Title.per_page
			  @paginate = true
			  @page = (params[:page] ? params[:page].to_i : 1)
			  @titles = Title.title_search(params[:title_text], params[:date], params[:publisher_text], params[:creator_text],
			                               (params[:collection_id] == '0' ? nil : params[:collection_id]), current_user, (@page - 1) * Title.per_page, Title.per_page)
		  else
			  @titles = Title.title_search(params[:title_text], params[:date], params[:publisher_text], params[:creator_text],
			                               (params[:collection_id] == '0' ? nil : params[:collection_id]), current_user, 0, @count)
		  end
	  end
	  render 'index'
  end

  # GET /titles/1
  # GET /titles/1.json
  def show
    @physical_objects = @title.physical_objects
    @component_group_cv = ControlledVocabulary.component_group_cv
  end

  # GET /titles/new_physical_object
  def new
    u = User.current_user_object
    @title = Title.new(modified_by_id: u.id, created_by_id: u.id)
  end

  # GET /titles/1/edit
  def edit
    @title.modified_by_id = User.current_user_object.id
    if @title.nil?
      flash.now[:warning] = "No such title..."
      redirect_to :back
    end
  end

  # POST /titles
  # POST /titles.json
  def create
    @title = Title.new(title_params)
    if @series
      @title.series_id = @series.id
    elsif !params[:title][:series_title_text].blank?
      @series = Series.new(title: params[:title][:series_title_text])
      @series.save
      @title.series_id = @series.id
    end
    respond_to do |format|
      if @title.save
        format.html { redirect_to @title, notice: 'Title was successfully created.' }
        format.json { render :show, status: :created, location: @title }
      else
        format.html { render :new_physical_object }
        format.json { render json: @title.errors, status: :unprocessable_entity }
      end
    end
  end

  def show_split_title
	  @title = Title.find(params[:id])
  end
  def update_split_title
	  @component_group_cv = ControlledVocabulary.component_group_cv
	  @title = Title.find(params[:id])
	  # map { title_1_id: {cg_type1: [array of physical object ids], ..., cg_typeN: [array of physical object ids] }, ..., title_N_id: {}}
	  # a title id of '' means @title - no reassignment
	  @map = JSON.parse(params[:map])

	  # pos returned to storage
	  @returned = []
	  # physical objects retitled
	  @retitled = []
	  # physical objects queued for pull
	  @queued = []

	  Title.transaction do
		  @map.keys.each do |title_id|
			  other_title = nil
			  if (!title_id.blank? && title_id != @title.id.to_s)
				  # convert the id into the active record
				  other_title = Title.find(title_id)
			  end
			  @map[title_id].keys.each do |cg_type|
				  cg = cg_type.blank? ? nil : ComponentGroup.new(title_id: (other_title.nil? ? @title.id : other_title.id), group_type: cg_type)
				  @map[title_id][cg_type].each do |p|
					  p = PhysicalObject.find(p)
					  # order matters... clear the active component group BEFORE assigning new workflow status
					  p.active_component_group = nil

					  # this physical object is being reassigned to another title so delete the title association and remove it from all component groups for the old title
					  if (!other_title.nil? && other_title != @title)
						  @title.component_groups.each do |cgi|
							  ComponentGroupPhysicalObject.where(component_group_id: cgi.id, physical_object_id: p.id).delete_all
						  end
						  PhysicalObjectTitle.where(title_id: @title.id, physical_object_id: p.id).delete_all
						  other_title.physical_objects << p
						  other_title.save
						  @retitled << p
					  end

					  ws = nil
					  # back to storage if no component group type specified
					  if cg.nil?
						  ws = WorkflowStatus.build_workflow_status(p.storage_location, p, true)
						  p.workflow_statuses << ws
						  p.save
						  @returned << p
					  else
						  cg.physical_objects << p
						  p.active_component_group = cg

						  # if reformatting, move to 2k/4k shelves, otherwise it needs to move to the respective best copy shelf (Alf/Wells)
						  if cg.group_type == ComponentGroup::REFORMATTING_MDPI
							  ws = WorkflowStatus.build_workflow_status(WorkflowStatus::TWO_K_FOUR_K_SHELVES, p, true)
						  else
							  ws = WorkflowStatus.build_workflow_status((cg.group_type == ComponentGroup::BEST_COPY_ALF ? WorkflowStatus::BEST_COPY_ALF : WorkflowStatus::BEST_COPY_WELLS), p, true)
						  end
						  p.workflow_statuses << ws
						  p.save
					  end
				  end
				  cg.save unless cg.nil?

				  # after adding all the PO's to a new component group we need to check if it was a new title assignmenet for a new CG
				  # if yes, any physical objects that were part of the new title and not part of the old title and in storage, need to be added to (only) best copy cgs and queued
				  if (!other_title.nil? && other_title != @title && !cg.nil? && cg.group_type != ComponentGroup::REFORMATTING_MDPI)
					  # add in storage pos to the best copy component group and queue
					  (cg.title.physical_objects.to_a - cg.physical_objects.to_a).each do |op|
						  if op.in_storage?
							  cg.physical_objects << op
							  op.active_component_group = cg
							  ws = WorkflowStatus.build_workflow_status(WorkflowStatus::QUEUED_FOR_PULL_REQUEST, op)
							  op.workflow_statuses << ws
							  op.save
							  @queued << op
						  end
					  end
				  end
			  end
		  end
	  end


	  # is this necessary still?
	  @returned = @returned.uniq{|p| p.id}
	  @retitled = @retitled.uniq{|p| p.id}
	  @queued = @queued.uniq{|p| p.id}

  end

  def create_component_group
    @component_group_cv = ControlledVocabulary.component_group_cv
    po_ids = params[:pos][:po_ids].split(",")
    # make sure that all submitted po ids actually belong to the title
    pos = PhysicalObject.where(id: po_ids)
    bad = pos.reject { |p| p.belongs_to_title? @title.id }.collect { |p| p.iu_barcode }
    respond_to do |format|
      if bad.size > 0
        format.html { render :show, warning: "The following Physical Objects do not belong to this title: #{bad.map(&:inspect).join(", ")}"}
      else
        cg = nil
        ComponentGroup.transaction do
          cg = ComponentGroup.new(
            group_type: params[:pos][:group_type], title_id: @title.id,
            group_summary: params[:pos][:group_summary],
            scan_resolution: (params['HD'] ? 'HD' : (params['5k'] ? '5k' : (params['4k'] ? '4k' : params['2k'] ? '2k' : nil))),
            return_on_reel: (params[:pos][:return_on_reel] == 'Yes' ? true : false),
            clean: params[:pos][:clean],
            color_space: params[:pos][:color_space]
          )
          cg.save!
          pos.each do |p|
            ComponentGroupPhysicalObject.new(physical_object_id: p.id, component_group_id: cg.id).save!
          end
        end
        format.html { redirect_to title_path(@title), notice: "Component Group <i>#{cg.group_type}</i> Created." }
      end
    end
  end

  def new_ajax
    u = User.current_user_object
    @title = Title.new(modified_by_id: u.id, created_by_id: u.id);
    @series = Series.where(id: params[:series_id]).first
    @title.series = @series
    render partial: 'form'
  end

  def create_ajax
    @title = Title.new(title_params)
    if @series
      @title.series_id = @series.id
    elsif !params[:title][:series_title_text].blank?
      @series = Series.new(title: params[:title][:series_title_text])
      @series.save
      @title.series_id = @series.id
    end
    respond_to do |format|
      if @title.save
        format.json {render json: {title_id: @title.id, title_text: @title.title_text, series_id: (@series.nil? ? 0 : @series.id), series_title: @series.nil? ? '' : @series.title}, status: :created}
      else
        format.json {
          render json: { error: 'Something bad happened while trying to save the title...', status: :unprocessable_entity }
        }
      end
    end
  end

  # PATCH/PUT /titles/1
  # PATCH/PUT /titles/1.json
  def update
    respond_to do |format|
	    @tp = title_params
	    if !@series && !params[:title][:series_title_text].blank?
		    @series = Series.new(title: params[:title][:series_title_text])
		    @series.save
		    @tp[:series_id] = @series.id
	    end
      if @title.update(@tp)
        format.html { redirect_to @title, notice: 'Title was successfully updated.' }
        format.json { render :show, status: :ok, location: @title }
      else
        format.html { render :edit }
        format.json { render json: @title.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /titles/1
  # DELETE /titles/1.json
  def destroy
    authorize Title
    if @title.physical_objects.size == 0
      @title.destroy
      respond_to do |format|
        format.html { redirect_to titles_url, notice: 'Title was successfully destroyed.' }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        flash[:warning] = "Cannot delete a Title that has Physical Objects"
        format.html {redirect_to @title}
      end
    end
  end

  # title merge from search page
  def titles_merge
	  @titles = Title.where(id: params[:title_ids].split(',').collect { |t| t.to_i })
  end

  # post for merging titles from search page
  def merge_titles
	  @master = Title.find(params[:master])
	  @mergees = Title.where(id: params[:selected].split(','))
	  failed = title_merge(@master, @mergees)
	  if failed.size > 0
		  links = failed.collect{ |t| view_context.link_to t.title_text, title_path(t), target: '_blank' }.join(', ')
		  flash[:warning] = "The following Titles are in active workflow and were not merged: #{links}"
	  end
	  if @mergees.size > failed.size
		  flash[:notice] = "#{@mergees.size - failed.size} Title(s) were merged into #{@master.title_text}"
	  end
	  redirect_to @master
  end

  # returns an array containing the total count of physical objects for this title at index 0,
  # followed by the total count of physical objects in active workflow at index 1
  def ajax_reel_count
	  @title = Title.find(params[:id])
	  c = 0
	  @title.physical_objects.each do |p|
		  cs = p.current_workflow_status
		  c += 1 if (!cs.nil? && !WorkflowStatus.is_storage_status?(cs.status_name)) &&	cs.status_name != WorkflowStatus::JUST_INVENTORIED_ALF && cs.status_name != WorkflowStatus::JUST_INVENTORIED_WELLS
	  end
	  ar = [@title.physical_objects.size, c]
	  render json: ar
	end


  ##### These actions are all related to handling title merge through the "title autocomplete" selection process ######
  # get for title merging from ajax autcomplete title selection
  def title_merge_selection

  end
  # ajax page returns a table row for the specified title
  def title_merge_selection_table_row
    @title = Title.find(params[:id])
    render partial: 'title_merge_selection_table_row'
  end
  # ajax call that renders a table containing all the physical objects for the specified title ids
  def merge_physical_object_candidates
	  @physical_objects = Title.where(id: params[:ids]).collect{ |t| t.physical_objects }.flatten
	  @component_group_cv = ControlledVocabulary.component_group_cv
	  render partial: 'merge_physical_object_candidates'
  end
  # does the actual title merge for ajax search based merging
  def merge_autocomplete_titles
	  @component_group_cv = ControlledVocabulary.component_group_cv
    @master = Title.find(params[:master_title_id])
    @title = @master
    if @master.nil?
      flash.now[:warning] = "You did not specify a master title record - merge aborted"
      redirect_to 'title_merge_selection'
    else
	    # 1) Merge the titles
	    @mergees = Title.where("id in (?)", params[:mergees].split(',').collect{ |s| s.to_i})
	    title_merge(@master, @mergees, true)
      # 2) Create any necessary component group
	    @physical_objects = PhysicalObject.where("id in (?)", params[:cg_pos].split(',').collect{ |s| s.to_i})
	    @queued = 0
	    @returned = 0
	    sum = "This Component Group was created by merging titles."
	    if @physical_objects.size > 0
		    @cg = ComponentGroup.new(
			    title_id: @master.id,
			    group_type: params[:group_type], title_id: @title.id,
			    group_summary: (params[:group_summary] + (params[:group_summary].blank? ? sum : " | #{sum}")),
			    scan_resolution: (params['HD'] ? 'HD' : (params['5k'] ? '5k' : (params['4k'] ? '4k' : params['2k'] ? '2k' : nil))),
			    return_on_reel: (params[:return_on_reel] == 'Yes' ? true : false),
			    clean: params[:clean],
			    color_space: params[:color_space],
			    return_on_reel: params[:return_on_reel]
		    )
		    # update physical objects in the component group
		    @physical_objects.each do |p|
			    @cg.component_group_physical_objects << ComponentGroupPhysicalObject.new(component_group_id: @cg.id, physical_object_id: p.id)
			    p.active_component_group = @cg
			    # queue pulls for any CG physical objects that are in storage
			    if WorkflowStatus::STATUS_TYPES_TO_STATUSES['Storage'].include?(p.current_workflow_status.status_name)
				    ws = WorkflowStatus.build_workflow_status(WorkflowStatus::QUEUED_FOR_PULL_REQUEST, p, true)
				    p.workflow_statuses << ws
				    p.save
				    @queued += 1
				    p.workflow_statuses << ws
			    else
				    loc = (@cg.group_type == ComponentGroup::BEST_COPY_ALF ? WorkflowStatus::BEST_COPY_ALF : WorkflowStatus::TWO_K_FOUR_K_SHELVES)
				    ws = WorkflowStatus.build_workflow_status(loc, p, true)
				    p.workflow_statuses << ws
			    end
			    p.save
		    end
		    @cg.save
	    end

	    # 3) Update physical objects not in the component group
	    others = @master.physical_objects.to_a - @physical_objects.to_a
	    others.each do |p|
		    in_storage = WorkflowStatus.is_storage_status?(p.current_workflow_status.status_name)
		    shipped = p.current_location == WorkflowStatus::SHIPPED_EXTERNALLY
		    if (shipped || in_storage)
			    next
		    else
			    ws = WorkflowStatus.build_workflow_status(p.storage_location, p, true)
			    p.workflow_statuses << ws
			    p.save
			    @returned += 1
		    end 
	    end
    end
	  @title.reload
    flash[:merge] = true
    render 'titles/show'
  end




  def new_physical_object
    @em = 'Creating New Physical Object'
    @physical_object = PhysicalObject.new
    @physical_object.titles << @title
    render 'physical_objects/new_physical_object'
  end

  def autocomplete_title
    if params[:term]
      if params[:exclude]
        @titles = Title.joins("LEFT JOIN `series` ON `series`.`id` = `titles`.`series_id`").where("title_text like ? AND titles.id not in (?)", "%#{params[:term]}%", params[:exclude]).select('titles.id, title_text, titles.summary, series_id, series.title')
      else
        @titles = Title.joins("LEFT JOIN `series` ON `series`.`id` = `titles`.`series_id`").where("title_text like ? ", "%#{params[:term]}%").select('titles.id, title_text, titles.summary, series_id, series.title')
      end
      json = @titles.to_json
      json.gsub! "\"title_text\":", "\"label\":"
      json.gsub! "\"id\":", "\"value\":"
      json.gsub! "\"title\":", "\"series_title\":"
      render json: json
    else
      render json: ''
    end
  end


  def autocomplete_title_for_series
    if params[:series_id] && params[:term]
      json = Title.where("series_id = ? and title_text like ?", params[:series_id], "%#{params[:term]}%").select(:id, :title_text, :summary).to_json
      json.gsub! "\"title_text\":", "\"label\":"
      json.gsub! "\"id\":", "\"value\":"
      render json: json
    else
      render json: ''
    end
  end

  def ajax_summary
    #@title = Title.find(params[:id]).to_json(include: [:title_creators, :title_dates, :title_original_identifiers, :title_publishers, :title_genres, :title_forms, :title_locations])
    #render :json => @title
    render partial: 'ajax_show'
  end

  def autocomplete_title_for_collection

  end

  def ajax_edit_cg_params
    @cg = ComponentGroup.find(params[:id])
	  render partial: 'ajax_edit_cg_params'
  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_title
    @title = Title.find(params[:id])
    @series = @title.series
  end

  def set_series
    @series = Series.find(params[:title][:series_id]) unless params[:title][:series_id].blank?
  end

  def set_all_title_cv
    set_form_cv
    set_genre_cv
    set_title_cv
  end
  def set_physical_object_cv
    @cv = ControlledVocabulary.physical_object_cv
    @l_cv = ControlledVocabulary.language_cv
    @pod_cv = ControlledVocabulary.physical_object_date_cv
  end
  def set_title_cv
    @title_cv = ControlledVocabulary.title_cv
	  @title_date_cv = ControlledVocabulary.title_date_cv
  end
  def set_form_cv
    @form_cv = ControlledVocabulary.title_form_cv
  end
  def set_genre_cv
    @genre_cv = ControlledVocabulary.title_genre_cv
  end
  def set_creator_cv

  end
  # Never trust parameters from the scary internet, only allow the white list through.
  def title_params
    params.require(:title).permit(
        :title_text, :summary, :series_id, :series_title_index, :modified_by_id, :created_by_id, :series_part, :notes, :subject, :name_authority,
        title_creators_attributes: [:id, :name, :role, :_destroy],
        title_dates_attributes: [:id, :date_text, :date_type, :_destroy],
        title_genres_attributes: [:id, :genre, :_destroy],
        title_original_identifiers_attributes: [:id, :identifier, :identifier_type, :_destroy],
        title_publishers_attributes: [:id, :name, :publisher_type, :_destroy],
        title_forms_attributes: [:id, :form, :_destroy],
        title_locations_attributes: [:id, :location, :_destroy]
    )
  end
  def page_link_path(page)
	  titles_search_path(page: page, title_text: params[:title_text], date: params[:date], publisher_text: params[:publisher_text], creator_text: params[:creator_text],
	                     collection_id: (params[:collection_id] == '0' ? 0 : params[:collection_id]))
  end
	helper_method :page_link_path
end
