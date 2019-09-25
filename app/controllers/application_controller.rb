class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper
  include Pundit

  before_action :signed_in_user

  around_filter :scope_current_username
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def public_home

  end

  # this finds what the user has selected from the MEDIUM attribute drop down and converts it to a symbol. See
  # find_original_physical_object_type below for more details
  def find_medium(params)
    type = find_original_physical_object_type(params)
    params[type][:medium].downcase.parameterize.underscore.to_sym
  end

  # This method extracts the Physical Object base class has key (:film, :video, etc) from the params hash.
  #
  # This is needed because when rails builds the form for a PhysicalObject, all attributes are named based on BASE
  # class and the the key to these is the base class: for instance, iu_barcode would be params[:film][:iu_barcode] if
  # the form was build around a Film object, params[:video][:iu_barcode] if the form was build around a Video object.
  # This results in a params hash with the key to the physical object attributes being the original form BASE
  # class: params[:film], params[:video], etc. This is mainly used when a user edits the Medium attribute for a
  # Physical Object. If a user creates a new Physical Object, the base class defaults to Film but when the user changes
  # that to video, a new form must be generated based on Video attributes. However, any physical object super class
  # attributes (barcodes, titles, etc) may have already been entered and these should be retained and copied into the
  # new physical object type
  def find_original_physical_object_type(params)
    type = nil
    type = :film if params[:film]
    type = :video if params[:video]
    raise "Invalid request - no supported formats specified: #{params.keys.join(', ')}" if type.nil?
    type
  end

  def page_link_path(page)
    physical_objects_path(page: page, status: params[:status], digitized: params[:digitized])
  end
  def physical_object_specific_path
    @physical_object.medium.downcase.parameterize.underscore
  end
  def physical_object_specific_medium
    @physical_object.medium.downcase.parameterize.underscore
  end
  helper_method :page_link_path
  helper_method :physical_object_specific_medium
  helper_method :physical_object_specific_path

  private
  def scope_current_username
    User.current_username = current_username
    yield
  ensure
    User.current_username = nil
  end

  def user_not_authorized(exception)
    flash[:warning] = "You are not authorized to #{meaningful_action_name(action_name).humanize.downcase} #{controller_name.humanize.split.map(&:capitalize)*' '}"
    redirect_to request.referrer || root_path
  end

  def meaningful_action_name(name)
    name == 'index' ? 'View' : (name == 'destroy' ? 'Delete' : name)
  end

  # def update_user_loc
  #   if session[:username]
		#   @user = User.where(username: session[:username]).first
		#   if (@user.works_in_both_locations && (@user.updated_at + SessionsHelper::TIME_OUT < Time.now)) || (!@user.works_in_both_locations && @user.worksite_location.blank?)
		# 	  session[:return_to] = request.fullpath
		# 	  redirect_to show_worksite_location_path(@user.id)
		#   end
  #   end
  # end
end
