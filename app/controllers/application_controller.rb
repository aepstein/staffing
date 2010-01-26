class ApplicationController < ActionController::Base
  helper :all
  protect_from_forgery
  helper_method :current_user, :current_user_session
  before_filter :check_authorization

  def permission_denied
    flash[:error] = "You are not authorized to access the page you requested."
    redirect_to profile_url
  end

  # If user has been authenticated with single sign on credentials, logs in immediately
  def sso_net_id
    return false unless request.env['REMOTE_USER'] && request.env['REMOTE_USER'].valid_net_id?
    request.env['REMOTE_USER']
  end

  private
  def check_authorization
    Authorization.current_user = current_user
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    @current_user = current_user_session && current_user_session.record
    return nil if sso_net_id && (@current_user.nil? || @current_user.net_id != sso_net_id)
    @current_user
  end

  def require_user
    unless current_user
      store_location
      flash[:notice] = 'You must log in to access this page.'
      redirect_to login_url
    end
  end

  def require_no_user
    if current_user || @current_user
      redirect_to logout_url
    end
  end

  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

end

