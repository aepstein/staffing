class EnrollmentsController < ApplicationController
  before_filter :initialize_context
  before_filter :setup_breadcrumbs
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
    @enrollments = @enrollments.ordered

    respond_to do |format|
      format.html { render :action => 'index' } # index.html.erb
      format.xml  { render :xml => @enrollments }
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

