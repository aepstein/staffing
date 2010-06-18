class UsersController < ApplicationController
  before_filter :require_user, :initialize_context
  before_filter :initialize_index, :only => [ :index ]
  before_filter :new_user_from_params, :only => [ :new, :create ]
  before_filter :set_admin_properties, :only => [ :create, :update ]
  filter_access_to :new, :create, :edit, :update, :destroy, :show, :attribute_check => true

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
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/resume.pdf
  def resume
    respond_to do |format|
      format.pdf do
        if @user.resume.file?
          send_file @user.resume.path, :filename => "#{@user.name :file}-resume.pdf", :type => @user.resume.content_type
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
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @user = User.find params[:id] if params[:id]
    @membership = Membership.find params[:membership_id] if params[:membership_id]
  end

  def initialize_index
    @users = User
    @users = @membership.users if @membership
  end

  def new_user_from_params
    @user = User.new( params[:user] )
  end

  def set_admin_properties
    if current_user.admin? && params[:user]
      @user.admin = params[:user][:admin] unless params[:user][:admin].blank?
      @user.net_id = params[:user][:net_id] unless params[:user][:net_id].blank?
      @user.statuses = [params[:user][:statuses]].flatten unless params[:user][:statuses].blank?
    end
  end
end

