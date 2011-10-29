class UserSessionsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy

  LOGIN_NOTICE = "You logged in successfully."
  LOGOUT_NOTICE = "You logged out successfully."

  # GET /login
  def new; end

  # POST /user_session
  def create
    return permission_denied if sso_net_id
    user = User.find_by_net_id(params[:net_id])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_url, :notice => LOGIN_NOTICE
    else
      flash.now.alert = "Invalid net id or password"
      render "new"
    end
  end

  # GET /logout
  def destroy
    return permission_denied if sso_net_id
    session[:user_id] = nil
    redirect_to login_url, :notice => LOGOUT_NOTICE
  end
end

