class UserSessionsController < ApplicationController
  before_filter :require_no_user, only: [:new, :create]
  before_filter :require_user, only: :destroy

  LOGIN_NOTICE = "You logged in successfully."
  LOGOUT_NOTICE = "You logged out successfully."
  
  # /sso/:provider/login
  def sso_login
    if sso_net_id
      if current_user.blank?
        redirect_to sso_register_path, flash: { notice: 'You must register to access this page.' }
      else
        redirect_to root_url, notice: LOGIN_NOTICE
      end
    else
      render action: :new
    end
  end

  # GET /login
#  def new
#    respond_to do |format|
#      format.html do
#        if sso_net_id && current_user.blank?
#          redirect_to sso_register_path, flash: { notice: 'You must register to access this page.' }
#        else
#          render action: :new
#        end
#      end
#    end
#  end

  # POST /user_session
  def create
    return permission_denied if sso_net_id
    user = User.find_by_net_id(params[:net_id])
    if user && user.authenticate(params[:password])
      reset_session
      session[:user_id] = user.id
      redirect_to root_url, notice: LOGIN_NOTICE
    else
      flash.now.alert = "Invalid net id or password"
      render "new"
    end
  end

  # GET /logout
  def destroy
    return permission_denied if sso_net_id
    reset_session
    redirect_to login_url, notice: LOGOUT_NOTICE
  end
end

