class MeetingsController < ApplicationController
  before_filter :initialize_context
  before_filter :new_meeting_from_params, :only => [ :new, :create ]
  before_filter :initialize_index, :only => [ :current, :past, :future, :index ]
  filter_access_to :new, :create, :edit, :update, :destroy, :show
  filter_access_to :index, :current, :past, :future do
    true
  end

  # GET /meetings/current
  # GET /meetings/current.xml
  # GET /committees/:committee_id/meetings/current
  # GET /committees/:committee_id/meetings/current.xml
  # GET /motions/:motion_id/meetings/current
  # GET /motions/:motion_id/meetings/current.xml
  def current
    @meetings = @meetings.current
    index
  end

  # GET /meetings/past
  # GET /meetings/past.xml
  # GET /committees/:committee_id/meetings/past
  # GET /committees/:committee_id/meetings/past.xml
  # GET /motions/:motion_id/meetings/past
  # GET /motions/:motion_id/meetings/past.xml
  def past
    @meetings = @meetings.past
    index
  end

  # GET /meetings/future
  # GET /meetings/future.xml
  # GET /committees/:committee_id/meetings/future
  # GET /committees/:committee_id/meetings/future.xml
  # GET /motions/:motion_id/meetings/future
  # GET /motions/:motion_id/meetings/future.xml
  def future
    @meetings = @meetings.future
    index
  end

  # GET /committees/:committee_id/meetings
  # GET /committees/:committee_id/meetings.xml
  # GET /motions/:motion_id/meetings
  # GET /motions/:motion_id/meetings.xml
  def index
    respond_to do |format|
      format.html { render :action => 'index' } # index.html.erb
      format.xml  { render :xml => @meetings }
    end
  end

  # GET /meetings/1
  # GET /meetings/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @meeting }
    end
  end

  # GET /committees/:committee_id/meetings/new
  # GET /committees/:committee_id/meetings/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @meeting }
    end
  end

  # GET /meetings/1/edit
  def edit
    @meeting.meeting_motions.build
  end

  # POST /committees/:committee_id/meetings
  # POST /committees/:committee_id/meetings.xml
  def create
    respond_to do |format|
      if @meeting.save
        flash[:notice] = 'Meeting was successfully created.'
        format.html { redirect_to(@meeting) }
        format.xml  { render :xml => @meeting, :status => :created, :location => @meeting }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @meeting.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /meetings/1
  # PUT /meetings/1.xml
  def update
    respond_to do |format|
      if @meeting.update_attributes(params[:meeting])
        flash[:notice] = 'Meeting was successfully updated.'
        format.html { redirect_to(@meeting) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @meeting.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /meetings/1
  # DELETE /meetings/1.xml
  def destroy
    @meeting.destroy

    respond_to do |format|
      format.html { redirect_to committee_meetings_url @meeting.committee }
      format.xml  { head :ok }
    end
  end

  private

  def new_meeting_from_params
    @meeting = @committee.meetings.build
    @meeting.attributes = params[:meeting]
  end

  def initialize_index
    @meetings = Meeting.scoped
    @meetings = @meetings.where(:committee_id => @committee.id) if @committee
    @meetings = @meetings.where(:motion_id => @motion.id) if @motion
  end

  def initialize_context
    @meeting = Meeting.find(params[:id]) if params[:id]
    @committee = Committee.find(params[:committee_id]) if params[:committee_id]
    @motion = Motion.find(params[:motion_id]) if params[:motion_id]
  end
end
