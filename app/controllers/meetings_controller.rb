class MeetingsController < ApplicationController
  before_filter :initialize_context
  filter_access_to :new, :create, :edit, :update, :destroy, :show
  filter_access_to :index, :current, :past, :future do
    @user ? permitted_to!( :show, @user ) : permitted_to!( :show, @committee )
  end

  # GET /users/:user_id/meetings/current
  # GET /users/:user_id/meetings/current.xml
  def current
    @meetings ||= @user.current_meetings if @user
    index
  end

  # GET /users/:user_id/meetings/past
  # GET /users/:user_id/meetings/past.xml
  def past
    @meetings ||= @user.past_meetings if @user
    index
  end

  # GET /users/:user_id/meetings/future
  # GET /users/:user_id/meetings/future.xml
  def future
    @meetings ||= @user.future_meetings if @user
    index
  end

  # GET /committees/:committee_id/meetings
  # GET /committees/:committee_id/meetings.xml
  # GET /users/:user_id/meetings
  # GET /users/:user_id/meetings.xml
  def index
    @meetings ||= @committee.meetings if @committee
    @meetings ||= @user.meetings if @user

    respond_to do |format|
      format.html { render :action => 'index' } # index.html.erb
      format.xml  { render :xml => @meetings }
    end
  end

  # GET /meetings/1
  # GET /meetings/1.xml
  def show
    @meeting = Meeting.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @meeting }
    end
  end

  # GET /committees/:committee_id/meetings/new
  # GET /committees/:committee_id/meetings/new.xml
  def new
    @meeting = Committee.find(params[:committee_id]).meetings.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @meeting }
    end
  end

  # GET /meetings/1/edit
  def edit
    @meeting = Meeting.find(params[:id])
  end

  # POST /committees/:committee_id/meetings
  # POST /committees/:committee_id/meetings.xml
  def create
    @meeting = Committee.find(params[:committee_id]).meetings.build(params[:meeting])

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
    @meeting = Meeting.find(params[:id])

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
    @meeting = Meeting.find(params[:id])
    @meeting.destroy

    respond_to do |format|
      format.html { redirect_to committee_meetings_url @meeting.committee }
      format.xml  { head :ok }
    end
  end

  private
  def initialize_context
    @committee = Committee.find(params[:committee_id]) if params[:committee_id]
    @user = User.find(params[:user_id]) if params[:user_id]
  end
end

