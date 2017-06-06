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
end
