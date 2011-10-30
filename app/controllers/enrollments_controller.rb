class EnrollmentsController < ApplicationController
  before_filter :initialize_context
  before_filter :new_enrollment_from_params, :only => [ :new, :create ]
  before_filter :setup_breadcrumbs
  filter_access_to :new, :create, :edit, :update, :destroy, :show
  filter_access_to :index, :current, :past, :future do
    @user ? permitted_to!( :show, @user ) : permitted_to!( :show, @committee )
  end

  # GET /users/:user_id/enrollments/current
  # GET /users/:user_id/enrollments/current.xml
  def current
    if @user
      @enrollments = @user.enrollments.current
      add_breadcrumb 'Current', current_user_enrollments_path(@user)
    end
    index
  end

  # GET /users/:user_id/enrollments/past
  # GET /users/:user_id/enrollments/past.xml
  def past
    if @user
      @enrollments = @user.enrollments.past
      add_breadcrumb 'Past', past_user_enrollments_path(@user)
    end
    index
  end

  # GET /users/:user_id/enrollments/future
  # GET /users/:user_id/enrollments/future.xml
  def future
    if @user
      @enrollments = @user.enrollments.future
      add_breadcrumb 'Future', future_user_enrollments_path(@user)
    end
    index
  end

  # GET /committees/:committee_id/enrollments
  # GET /committees/:committee_id/enrollments.xml
  # GET /users/:user_id/enrollments
  # GET /users/:user_id/enrollments.xml
  def index
    @enrollments ||= @committee.enrollments if @committee
    @enrollments ||= @user.enrollments if @user

    respond_to do |format|
      format.html { render :action => 'index' } # index.html.erb
      format.xml  { render :xml => @enrollments }
    end
  end

  # GET /enrollments/1
  # GET /enrollments/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @enrollment }
    end
  end

  # GET /committees/:committee_id/enrollments/new
  # GET /committees/:committee_id/enrollments/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @enrollment }
    end
  end

  # GET /enrollments/1/edit
  def edit
  end

  # POST /committees/:committee_id/enrollments
  # POST /committees/:committee_id/enrollments.xml
  def create
    respond_to do |format|
      if @enrollment.save
        flash[:notice] = 'Enrollment was successfully created.'
        format.html { redirect_to(@enrollment) }
        format.xml  { render :xml => @enrollment, :status => :created, :location => @enrollment }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @enrollment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /enrollments/1
  # PUT /enrollments/1.xml
  def update
    respond_to do |format|
      if @enrollment.update_attributes(params[:enrollment])
        flash[:notice] = 'Enrollment was successfully updated.'
        format.html { redirect_to(@enrollment) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @enrollment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /enrollments/1
  # DELETE /enrollments/1.xml
  def destroy
    @enrollment.destroy

    respond_to do |format|
      format.html { redirect_to committee_enrollments_url @enrollment.committee }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @enrollment = Enrollment.find(params[:id]) if params[:id]
    @committee = Committee.find(params[:committee_id]) if params[:committee_id]
    if @enrollment
      @committee ||= @enrollment.committee
    end
    @user = User.find(params[:user_id]) if params[:user_id]
  end

  def new_enrollment_from_params
    @enrollment = @committee.enrollments.build(params[:enrollment])
  end

  def setup_breadcrumbs
    if @user
      add_breadcrumb 'Users', users_path
      add_breadcrumb @user.name, user_path(@user)
      add_breadcrumb 'Enrollments', user_enrollments_path(@user)
    elsif @committee
      add_breadcrumb 'Committees', committees_path
      add_breadcrumb 'Enrollments', committee_enrollments_path( @committee )
    end
    if @enrollment && @enrollment.persisted?
      add_breadcrumb "#{@enrollment.title} (#{@enrollment.position})", enrollment_path( @enrollment )
    end
  end
end

