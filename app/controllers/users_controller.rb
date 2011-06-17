class UsersController < ApplicationController
  before_filter :require_user, :initialize_context
  before_filter :initialize_index, :only => [ :index, :allowed ]
  before_filter :new_user_from_params, :only => [ :new, :create ]
  filter_access_to :new, :create, :edit, :update, :destroy, :show,
    :attribute_check => true
  before_filter :setup_breadcrumbs, :except => [ :profile ]

  # GET /motions/:motion_id/users/allowed
  # GET /motions/:motion_id/users/allowed
  def allowed
    @users = @users.allowed
    add_breadcrumb "Allowed", polymorphic_path([ :allowed, @context, :users ])
    index
  end

  # GET /motions/:motion_id/users
  # GET /motions/:motion_id/users
  # GET /meetings/:meetings_id/users
  # GET /meetings/:meetings_id/users
  # GET /users
  # GET /users.xml
  def index
    @search = @users.with_permissions_to(:show).search(
      params[:term] ? { :name_like => params[:term] } : params[:search]
    )
    @users = @search.paginate(:page => params[:page])

    respond_to do |format|
      format.html { render :action => 'index' } # index.html.erb
      format.json { render :action => 'index' } # index.json.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/:id/tent.pdf
  def tent
    respond_to do |format|
      format.html { render :layout => 'tent' }
      format.pdf {
        report = UserTentReport.new(@user)
        send_data report.to_pdf, :filename => "#{@user.name :file}-tent.pdf",
          :type => 'application/pdf', :disposition => 'inline'
      }
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
          send_file @user.resume.path, :filename => "#{@user.name :file}-resume.pdf",
            :type => @user.resume.content_type, :disposition => 'inline'
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
    @user.accessible = User::ADMIN_UPDATABLE
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
    @motion = Motion.find params[:motion_id] if params[:motion_id]
    @context = @membership || @motion
  end

  def setup_breadcrumbs
    if @context
      add_breadcrumb @context.class.to_s.pluralize,
        polymorphic_path( [ @context.class.arel_table.name ] )
      add_breadcrumb @context, polymorphic_path( [ @context ] )
    end
    add_breadcrumb 'Users', polymorphic_path( [ @context, :users ] )
    if @user && @user.persisted?
      add_breadcrumb @user, user_path( @user )
    end
  end

  def initialize_index
    @users = User.scoped
    @users = @membership.users if @membership
    @users = @motion.users if @motion
  end

  def new_user_from_params
    @user = User.new
    @user.accessible = User::ADMIN_UPDATABLE
    @user.attributes = params[:user]
  end

end

