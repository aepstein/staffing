class MotionsController < ApplicationController
  before_filter :initialize_context
  before_filter :initialize_index
  before_filter :new_motion_from_params, :only => [ :new, :create ]
  filter_access_to :new, :create, :edit, :update, :destroy, :show, :attribute_check => true

  # GET /meetings/:meeting_id/motions/allowed
  # GET /meetings/:meeting_id/motions/allowed.xml
  def allowed
    @motions = @motions.allowed
    index
  end

  # GET /committees/:committee_id/motions
  # GET /committees/:committee_id/motions.xml
  # GET /meetings/:meeting_id/motions
  # GET /meetings/:meeting_id/motions.xml
  # GET /users/:user_id/motions
  # GET /users/:user_id/motions.xml
  # GET /motions
  # GET /motions.xml
  def index
    @search = @motions.with_permissions_to(:show).search(
      params[:term] ? { :name_contains => params[:term] } : params[:search]
    )
    @motions = @search.paginate(:page => params[:page])

    respond_to do |format|
      format.html { render :action => 'index' } # index.html.erb
      format.json { render :action => 'index' } # index.json.erb
      format.xml  { render :xml => @motions }
    end
  end

  # GET /motions/1
  # GET /motions/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @motion }
    end
  end

  # GET /committees/:committee_id/motions/new
  # GET /committees/:committee_id/motions/new.xml
  def new
    @motion.sponsorships.build unless @motion.sponsorships.populate_for( current_user )
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @motion }
    end
  end

  # GET /motions/1/edit
  def edit
    @motion.sponsorships.build
    respond_to do |format|
      format.html # edit.html.erb
    end
  end

  # POST /committees/:committee_id/motions
  # POST /committees/:committee_id/motions.xml
  def create
    respond_to do |format|
      if @motion.save
        flash[:notice] = 'Motion was successfully created.'
        format.html { redirect_to @motion }
        format.xml  { render :xml => @motion, :status => :created, :location => @motion }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @motion.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /motions/1
  # PUT /motions/1.xml
  def update
    if permitted_to? :manage, @motion
      [ :user_id, :period_id ].each do |k|
        @motion.send "#{k}=", params[k]  if params[k]
      end
    end
    respond_to do |format|
      if @motion.update_attributes(params[:motion])
        flash[:notice] = 'Motion was successfully updated.'
        format.html { redirect_to(@motion) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @motion.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /motions/1
  # DELETE /motions/1.xml
  def destroy
    @motion.destroy

    respond_to do |format|
      format.html { redirect_to committee_motions_url @motion.committee }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @committee = Committee.find(params[:committee_id]) if params[:committee_id]
    @user = User.find(params[:user_id]) if params[:user_id]
    @meeting = Meeting.find(params[:meeting_id]) if params[:meeting_id]
    @motion = Motion.find(params[:id]) if params[:id]
  end

  def initialize_index
    @motions = Motion.scoped
    @motions = @committee.motions if @committee
    @motions = @user.motions if @user
    @motions = @meeting.motions if @meeting
  end

  def new_motion_from_params
    @motion = @committee.motions.build( params[:motion] )
    @motion.period ||= @committee.periods.active
  end
end

