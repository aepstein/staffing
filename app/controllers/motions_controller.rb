class MotionsController < ApplicationController
  before_filter :initialize_context
  before_filter :initialize_index
  before_filter :new_motion_from_params, only: [ :new, :create ]
  before_filter :setup_breadcrumbs
  filter_access_to :new, :create, :edit, :update, :destroy, :show,
    :adopt, :divide, :implement, :merge, :propose, :refer, :reject,
    :restart, :withdraw,
    attribute_check: true
  filter_access_to :adopt, :divide, :implement, :merge, :propose, :refer, :reject,
    :restart, :withdraw do
    raise Authorization::NotAuthorized unless @motion.status_events.include? action_name.to_sym
    permitted_to! action_name, @motion
  end
  before_filter :status_check, except: [ :new, :create, :edit, :update,
    :show, :destroy, :allowed, :past, :current, :proposed, :index ]

  # GET /meetings/:meeting_id/motions/allowed
  # GET /meetings/:meeting_id/motions/allowed.xml
  def allowed
    @motions = @motions.allowed
    add_breadcrumb 'Allowed', polymorphic_path([:allowed, @context, :motions])
    index
  end

  # GET /committees/:committee_id/motions/past
  # GET /committees/:committee_id/motions/past.xml
  def past
    @motions = @motions.past
    add_breadcrumb 'Past', polymorphic_path([:past, @context, :motions])
    index
  end

  # GET /committees/:committee_id/motions/current
  # GET /committees/:committee_id/motions/current.xml
  def current
    @motions = @motions.current
    add_breadcrumb 'Current', polymorphic_path([:current, @context, :motions])
    index
  end

  # GET /committees/:committee_id/motions/proposed
  # GET /committees/:committee_id/motions/proposed.xml
  def proposed
    @motions = @motions.current.with_status(:proposed)
    add_breadcrumb 'Proposed', polymorphic_path([:proposed, @context, :motions])
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
      params[:term] ? { :name_cont => params[:term] } : params[:search]
    )
    @motions = @search.result.ordered.page( params[:page] )

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
    respond_to do |format|
      format.html # edit.html.erb
    end
  end

  # POST /committees/:committee_id/motions
  # POST /committees/:committee_id/motions.xml
  def create
    @motion.attachments.each { |a| a.attachable = @motion }
    respond_to do |format|
      if @motion.save
        format.html { redirect_to @motion, notice: 'Motion was successfully created.' }
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
    respond_to do |format|
      if @motion.update_attributes(params[:motion], as: ( permitted_to?(:admin) ? :admin : :default ))
        format.html { redirect_to @motion, notice: 'Motion was successfully updated.' }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @motion.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /motions/:id/propose
  def propose
    respond_to do |format|
      if @motion.propose
        format.html { redirect_to @motion, notice: 'Motion was successfully proposed.' }
        format.xml { head :ok }
      else
        format.html { redirect_to @motion, alert: 'Cannot propose the motion.' }
        format.xml { render xml: @motion.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /motions/:id/restart
  # TODO should have functionality similar to edit so chair or sponsor can alter sponsors, etc.
  def restart
    respond_to do |format|
      if @motion.restart
        format.html { redirect_to @motion, notice: 'Motion was successfully restarted.' }
        format.xml { head :ok }
      else
        format.html { redirect_to @motion, alert: 'Cannot restart the motion.' }
        format.xml { render xml: @motion.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /motions/:id/withdraw
  def withdraw
    respond_to do |format|
      if @motion.withdraw
        format.html { redirect_to @motion, notice: 'Motion was successfully withdrawn.' }
        format.xml { head :ok }
      else
        format.html { redirect_to @motion, alert: 'Cannot withdraw the motion.' }
        format.xml { render xml: @motion.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /motions/:id/merge - form where user selects motion to which this motion is to be merged
  # PUT /motions/:id/merge - do actual merge
  def merge
    @motion_merger = @motion.build_terminal_motion_merger(params[:motion_merger])
    respond_to do |format|
      if request.method_symbol == :get
        format.html { render action: :merge }
      else
        if @motion_merger.save
          format.html { redirect_to @motion.terminal_merged_motion,
            notice: 'Motion was successfully merged.' }
          format.xml { head :ok }
        else
          format.html { redirect_to @motion, alert: 'Cannot merge the motion.' }
          format.xml { render xml: @motion.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # GET /motions/:id/refer
  # PUT /motions/:id/refer
  def refer
    @motion.referred_motions.build_referee( params[:motion] )
    respond_to do |format|
      if request.method_symbol == :get
        format.html { render action: :refer }
      else
        if @motion.refer
          format.html { redirect_to(@motion, notice: 'Motion was successfully referred.') }
          format.xml  { head :ok }
        else
          format.html { render action: "refer" }
          format.xml  { render xml: @motion.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # GET /motions/:id/divide
  # PUT /motions/:id/divide
  def divide
    respond_to do |format|
      if request.method_symbol == :get
        format.html { render action: :divide }
      else
        @motion.assign_attributes( params[:motion], as: :divider )
        @motion.referred_motions.each { |m| m.committee = @motion.committee; m.published = true; m.period = @motion.period }
        if @motion.divide
          format.html { redirect_to(@motion, notice: 'Motion was successfully divided.') }
          format.xml  { head :ok }
        else
          format.html { render :action => "divide" }
          format.xml  { render :xml => @motion.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PUT /motions/:id/adopt
  def adopt
    respond_to do |format|
      if @motion.adopt
        format.html { redirect_to @motion, notice: 'Motion was successfully adopted.' }
        format.xml { head :ok }
      else
        format.html { redirect_to @motion, alert: 'Cannot adopt the motion.' }
        format.xml { render xml: @motion.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /motions/:id/implement
  def implement
    respond_to do |format|
      if @motion.implement
        format.html { redirect_to @motion, notice: 'Motion was successfully implemented.' }
        format.xml { head :ok }
      else
        format.html { redirect_to @motion, alert: 'Cannot implement the motion.' }
        format.xml { render xml: @motion.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /motions/:id/reject
  def reject
    respond_to do |format|
      if @motion.reject
        format.html { redirect_to @motion, notice: 'Motion was successfully rejected.' }
        format.xml { head :ok }
      else
        format.html { redirect_to @motion, alert: 'Cannot reject the motion.' }
        format.xml { render xml: @motion.errors, status: :unprocessable_entity }
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
    @motion = Motion.find(params[:id]) if params[:id]
    @meeting = Meeting.find(params[:meeting_id]) if params[:meeting_id]
    @user = User.find(params[:user_id]) if params[:user_id]
    @committee = Committee.find(params[:committee_id]) if params[:committee_id]
    @committee ||= @motion.committee if @motion
    @committee ||= @meeting.committee if @meeting
    @context = @user || @meeting || @committee
  end

  def initialize_index
    @motions = Motion.scoped
    @motions = @committee.motions if @committee
    @motions = @user.motions if @user
    @motions = @meeting.motions if @meeting
  end

  def new_motion_from_params
    @motion = @committee.motions.build( params[:motion],
      as: ( permitted_to?(:admin) ? :admin : :default ) )
    @motion.period ||= @motion.committee.periods.active
  end

  def setup_breadcrumbs
    add_breadcrumb 'Committees', committees_path
    if @committee
      add_breadcrumb @committee.name, committee_path(@committee)
    end
    if @meeting
      add_breadcrumb 'Meetings',
        polymorphic_path([ @committee, :meetings ])
      add_breadcrumb @meeting.tense.to_s.capitalize,
        polymorphic_path([ @meeting.tense, @committee, :meetings ])
      add_breadcrumb @meeting,
        meeting_path( @meeting )
    end
    if @user
      add_breadcrumb 'Users', users_path
      add_breadcrumb @user.name, user_path( @user )
    end
    add_breadcrumb 'Motions', polymorphic_path([ @context, :motions ])
    if @motion && @motion.persisted?
      add_breadcrumb @motion, motion_path(@motion)
    end
  end

  def status_check
  end
end

