class MeetingsController < ApplicationController
  before_filter :initialize_context
  before_filter :new_meeting_from_params, only: [ :new, :create ]
  before_filter :populate_meeting_sections, only: [ :new, :edit ]
  before_filter :initialize_index, only: [ :current, :past, :future, :index ]
  before_filter :setup_breadcrumbs
  filter_access_to :new, :create, :edit, :update, :destroy, :show,
    attribute_check: true
  filter_access_to :index, :current, :past, :future do
    true
  end
  filter_access_to :editable_minutes, :published_minutes, :audio do
    permitted_to! :show
  end

  # GET /meetings/:id/editable_minutes.(doc|odt|tex|txt)
  def editable_minutes
    send_file @meeting.editable_minutes.current_path,
      :filename => @meeting.to_s(:editable_minutes_file),
      :content_type => @meeting.editable_minutes.content_type,
      :disposition => 'attachment'
  end

  # GET /meetings/current
  # GET /meetings/current.xml
  # GET /committees/:committee_id/meetings/current
  # GET /committees/:committee_id/meetings/current.xml
  # GET /motions/:motion_id/meetings/current
  # GET /motions/:motion_id/meetings/current.xml
  def current
    @meetings = @meetings.current
    add_breadcrumb 'Current', polymorphic_path([ :current, @context, :meetings ])
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
    add_breadcrumb 'Past', polymorphic_path([ :past, @context, :meetings ])
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
    add_breadcrumb 'Future', polymorphic_path([ :future, @context, :meetings ])
    index
  end

  # GET /committees/:committee_id/meetings
  # GET /committees/:committee_id/meetings.xml
  # GET /motions/:motion_id/meetings
  # GET /motions/:motion_id/meetings.xml
  def index
    @q = @meetings.search( params[:q] )
    @meetings = @q.result.page( params[:page] )

    respond_to do |format|
      format.html { render action: 'index' } # index.html.erb
      format.xml  { render xml: @meetings }
    end
  end

  # GET /meetings/1
  # GET /meetings/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @meeting }
    end
  end

  # GET /committees/:committee_id/meetings/new
  # GET /committees/:committee_id/meetings/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @meeting }
    end
  end

  # GET /meetings/1/edit
  def edit
  end

  # POST /committees/:committee_id/meetings
  # POST /committees/:committee_id/meetings.xml
  def create
    respond_to do |format|
      if @meeting.save
        format.html { redirect_to( @meeting, notice: 'Meeting was successfully created.' ) }
        format.xml  { render xml: @meeting, status: :created, location: @meeting }
      else
        format.html { render action: "new" }
        format.xml  { render xml: @meeting.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /meetings/1
  # PUT /meetings/1.xml
  def update
    respond_to do |format|
      if @meeting.update_attributes(params[:meeting])
        format.html { redirect_to @meeting, notice: 'Meeting was successfully updated.' }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @meeting.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /meetings/1
  # DELETE /meetings/1.xml
  def destroy
    @meeting.destroy

    respond_to do |format|
      format.html { redirect_to( committee_meetings_url( @meeting.committee ),
        notice: "Meeting was successfully destroyed." ) }
      format.xml  { head :ok }
    end
  end

  private

  def new_meeting_from_params
    @meeting = @committee.meetings.build( params[:meeting] )
    @meeting.period ||= @committee.periods.active
  end

  def initialize_index
    @meetings = @committee.meetings if @committee
    @meetings = @motion.meetings if @motion
    @meetings ||= Meeting.scoped
    @meetings = @meetings.with_permissions_to(:show)
  end

  def initialize_context
    @meeting = Meeting.find(params[:id]) if params[:id]
    @committee = Committee.find(params[:committee_id]) if params[:committee_id]
    @motion = Motion.find(params[:motion_id]) if params[:motion_id]
    @committee ||= @meeting.committee if @meeting
    @committee ||= @motion.committee if @motion
    @context = @motion || @committee
  end

  def populate_meeting_sections
    @meeting.meeting_sections.populate
  end

  def setup_breadcrumbs
    add_breadcrumb 'Committees', committees_path
    if @committee
      add_breadcrumb @committee.name, committee_path(@committee)
    end
    if @motion
      add_breadcrumb 'Motions', committee_motions_path(@committee)
      add_breadcrumb @motion.tense.to_s.capitalize,
        polymorphic_path([ @motion.tense, @committee, :motions ])
      add_breadcrumb @motion.name, motion_path(@motion)
    end
    add_breadcrumb 'Meetings', polymorphic_path([ @context, :meetings ])
    if @meeting && @meeting.persisted?
      add_breadcrumb @meeting.tense.to_s.capitalize,
        polymorphic_path([ @meeting.tense, @context, :meetings ])
      add_breadcrumb @meeting, meeting_path( @meeting )
    end
  end
end

