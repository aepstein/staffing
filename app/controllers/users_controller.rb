class UsersController < ApplicationController
  before_filter :require_user
  filter_resource_access :collection => [ :index, :profile ]

  # GET /users
  # GET /users.xml
  def index
    @search = User.with_permissions_to(:show).search( params[:search] )
    @users = @search.paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.js # index.js.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/resume.pdf
  def resume
    @user = User.find(params[:id])

    respond_to do |format|
      format.pdf do
        if @user.resume.file?
          send_file @user.resume.path, :type => @user.resume.content_type
        else
          head(:not_found)
        end
      end
    end
  end

  # GET /profile
  def profile
    respond_to do |format|
      format.html # profile.html.erb
    end
  end


  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])
    if current_user.admin? && params[:user]
      @user.admin = params[:user][:admin] if params[:user][:admin]
      @user.net_id = params[:user][:net_id] if params[:user][:net_id]
      @user.status = params[:user][:status] if params[:user][:status]
    end

    respond_to do |format|
      if @user.save
        flash[:notice] = 'User was successfully created.'
        format.html { redirect_to(@user) }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])
    if current_user.admin? && params[:user]
      @user.admin = params[:user][:admin] if params[:user][:admin]
      @user.net_id = params[:user][:net_id] if params[:user][:net_id]
      @user.status = params[:user][:status] if params[:user][:status]
    end

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to(@user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end
end

