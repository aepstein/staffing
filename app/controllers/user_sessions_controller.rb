class UserSessionsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy

  LOGIN_NOTICE = "You logged in successfully."
  LOGOUT_NOTICE = "You logged out successfully."

  # GET /login
  def new
    if sso_net_id && ( user = User.find_by_net_id( sso_net_id ) )
      @user_session = UserSession.create( user, true )
      flash[:notice] = LOGIN_NOTICE
      redirect_back_or_default root_url
    else
      @user_session = UserSession.new
      respond_to do |format|
        format.html # show.html.erb
      end
    end
  end

  # POST /user_session
  def create
    @user_session = UserSession.new(params[:user_session])
    if ( @user_session.save )
      flash[:notice] = LOGIN_NOTICE
      redirect_back_or_default root_url
    else
      render :action => :new
    end
  end

  # GET /logout
  def destroy
    current_user_session.destroy
    flash[:notice] = LOGOUT_NOTICE
    redirect_back_or_default login_url
  end
end

