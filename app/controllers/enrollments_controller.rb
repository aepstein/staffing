class EnrollmentsController < ApplicationController
  before_filter :initialize_context
  filter_access_to :new, :create, :edit, :update, :destroy, :show, :index
  filter_access_to :current, :past, :future do
    permitted_to!( :show, @user ) || permitted_to!( :show, @committee )
  end

  # GET /users/:user_id/enrollments/current
  # GET /users/:user_id/enrollments/current.xml
  def current
    @enrollments ||= @user.current_enrollments if @user
    index
  end

  # GET /users/:user_id/enrollments/past
  # GET /users/:user_id/enrollments/past.xml
  def past
    @enrollments ||= @user.past_enrollments if @user
    index
  end

  # GET /users/:user_id/enrollments/future
  # GET /users/:user_id/enrollments/future.xml
  def future
    @enrollments ||= @user.future_enrollments if @user
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
    @enrollment = Enrollment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @enrollment }
    end
  end

  # GET /committees/:committee_id/enrollments/new
  # GET /committees/:committee_id/enrollments/new.xml
  def new
    @enrollment = Committee.find(params[:committee_id]).enrollments.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @enrollment }
    end
  end

  # GET /enrollments/1/edit
  def edit
    @enrollment = Enrollment.find(params[:id])
  end

  # POST /committees/:committee_id/enrollments
  # POST /committees/:committee_id/enrollments.xml
  def create
    @enrollment = Committee.find(params[:committee_id]).enrollments.build(params[:enrollment])

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
    @enrollment = Enrollment.find(params[:id])

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
    @enrollment = Enrollment.find(params[:id])
    @enrollment.destroy

    respond_to do |format|
      format.html { redirect_to committee_enrollments_url @enrollment.committee }
      format.xml  { head :ok }
    end
  end

  private
  def initialize_context
    @committee = Committee.find(params[:committee_id]) if params[:committee_id]
    @user = User.find(params[:user_id]) if params[:user_id]
  end
end

