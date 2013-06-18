class MotionsController < ApplicationController
  expose( :committee ) { Committee.find params[:committee_id] if params[:committee_id] }
  expose( :user ) { User.find params[:user_id] if params[:user_id] }
  expose( :meeting ) { Meeting.find params[:meeting_id] if params[:meeting_id] }
  expose( :period ) { Period.find params[:period_id] if params[:period_id] }
  expose( :context ) { meeting || user || committee }
  expose :q_scope do
    scope = context.motions if context
    scope ||= Motion.scoped
    case params[:action]
    when 'allowed'
      scope = scope.allowed
    when 'past', 'current'
      scope = scope.send params[:action]
    when 'proposed'
      scope = scope.send :with_status, :proposed
    else
      scope = scope.scoped
    end
    scope = scope.where( period_id: period.id ) if period
    scope
  end
  expose :q do
    q_scope.with_permissions_to(:show).search(
      params[:term] ? { name_cont: params[:term] } : params[:q]
    )
  end
  expose :motions do
    q.result.ordered.page(params[:page])
  end
  expose :amendment_attributes do
    permitted = Motion.permitted_attributes(:default) + Motion.permitted_attributes(:event)
    if params[:amendment]
      params.require(:amendment).permit( *permitted )
    else
      {}
    end
  end
  expose( :amendment ) do
    motion.referred_motions.build_amendment( amendment_attributes )
  end
  expose( :referred_motion_attributes ) do
    permitted = [ :committee_name ] + Motion.permitted_attributes(:event)
    if params[:referred_motion]
      params.require(:referred_motion).permit( *permitted )
    else
      {}
    end
  end
  expose :referred_motion do
    out = motion.referred_motions.build_referee( referred_motion_attributes )
    out.referring_motion.event_date, out.referring_motion.event_description = out.event_date, out.event_description
    out
  end
  expose :motion_attributes do
    permitted = *Motion.permitted_attributes( permitted_to?(:admin) ? :admin : :default )
    if params[:motion]
      params.require(:motion).permit( *permitted )
    else
      {}
    end
  end
  expose :event_motion_attributes do
    permitted = [ :id ] + Motion.permitted_attributes(:event)
    if params[:motion]
      params.require(:motion).permit( *permitted )
    else
      {}
    end
  end
  expose :motion do
    out = if params[:id]
      Motion.find params[:id]
    else
      source = ( meeting ? meeting.minute_motions : committee.motions )
      source.build( motion_attributes )
    end
    if out.new_record?
      out.committee ||= out.meeting.committee if out.meeting
      out.period ||= ( ( permitted_to?( :admin ) && meeting ) ? meeting.period : out.committee.periods.active )
    end
    out
  end
  expose(:motion_merger_attributes) do
    if params[:motion_merger]
      params.require(:motion_merger).permit( :merged_motion_id, :motion_id,
        { merged_motion_attributes: [ :id ] + Motion.permitted_attributes( :event ) } )
    else
      {}
    end
  end
  expose(:motion_merger) do
    motion.build_terminal_motion_merger do |merger|
      merger.assign_attributes motion_merger_attributes
    end
  end
  filter_access_to :new, :create, :edit, :update, :destroy, :show,
    :adopt, :amend, :divide, :implement, :merge, :propose, :refer, :reject,
    :restart, :unwatch, :watch, :withdraw,
    attribute_check: true, load_method: :motion
  filter_access_to :adopt, :amend, :divide, :implement, :merge, :propose,
    :refer, :reject, :restart, :withdraw do
    raise Authorization::NotAuthorized unless motion.status_events.include? action_name.to_sym
    permitted_to! action_name, motion
  end

  # GET /meetings/:meeting_id/motions/allowed
  # GET /meetings/:meeting_id/motions/allowed.xml
  def allowed
    index
  end

  # GET /committees/:committee_id/motions/past
  # GET /committees/:committee_id/motions/past.xml
  def past
    index
  end

  # GET /committees/:committee_id/motions/current
  # GET /committees/:committee_id/motions/current.xml
  def current
    index
  end

  # GET /committees/:committee_id/motions/proposed
  # GET /committees/:committee_id/motions/proposed.xml
  def proposed
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
    respond_to do |format|
      format.html { render action: 'index' } # index.html.erb
      format.json { render json: motions.map { |m| { label: m.to_s(:numbered), value: m.id } } }
    end
  end

  # GET /motions/1
  # GET /motions/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: motion }
      format.pdf do
        report = MotionReport.new( motion )
        send_data report.to_pdf, filename: "#{motion.to_s :file}.pdf",
          type: 'application/pdf', disposition: 'inline'
      end
    end
  end

  # GET /committees/:committee_id/motions/new
  # GET /committees/:committee_id/motions/new.xml
  def new
    motion.sponsorships.build unless motion.meeting || motion.sponsorships.populate_for( current_user )
    motion.populate_from_meeting
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: motion }
    end
  end

  # POST /committees/:committee_id/motions
  # POST /committees/:committee_id/motions.xml
  def create
    motion.attachments.each { |a| a.attachable = motion }
    respond_to do |format|
      if motion.save
        format.html { redirect_to motion, notice: 'Motion created.' }
        format.xml  { render xml: motion, status: :created, location: motion }
      else
        format.html { render action: "new" }
        format.xml  { render xml: motion.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /motions/1
  # PUT /motions/1.xml
  def update
    respond_to do |format|
      if motion.update_attributes( motion_attributes )
        format.html { redirect_to motion, notice: 'Motion updated.' }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: motion.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /motions/:id/watch
  def watch
    respond_to do |format|
      motion.watchers << current_user
      format.html { redirect_to motion, notice: 'You are now watching the motion.' }
      format.xml { head :ok }
    end
  end

  # PUT /motions/:id/unwatch
  def unwatch
    respond_to do |format|
      motion.watchers.delete current_user
      format.html { redirect_to motion, notice: 'You are no longer watching the motion.' }
      format.xml { head :ok }
    end
  end

  # GET /motions/:id/propose
  # PUT /motions/:id/propose
  def propose
    respond_to do |format|
      if request.method_symbol == :get
        format.html { render action: :propose }
      else
        motion.assign_attributes event_motion_attributes
        if motion.propose
          format.html { redirect_to(motion, notice: 'Motion proposed.') }
          format.xml  { head :ok }
        else
          format.html { render action: :propose }
          format.xml  { render xml: motion.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PUT /motions/:id/restart
  # TODO should have functionality similar to edit so chair or sponsor can alter sponsors, etc.
  def restart
    respond_to do |format|
      if motion.restart
        format.html { redirect_to motion, notice: 'Motion restarted.' }
        format.xml { head :ok }
      else
        format.html { redirect_to motion, alert: 'Cannot restart the motion.' }
        format.xml { render xml: motion.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /motions/:id/withdraw
  # PUT /motions/:id/withdraw
  def withdraw
    respond_to do |format|
      if request.method_symbol == :get
        format.html { render action: :withdraw }
      else
        motion.assign_attributes event_motion_attributes
        if motion.withdraw
          format.html { redirect_to(motion, notice: 'Motion withdrawn.') }
          format.xml  { head :ok }
        else
          format.html { render action: :withdraw }
          format.xml  { render xml: motion.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # GET /motions/:id/merge - form where user selects motion to which this motion is to be merged
  # PUT /motions/:id/merge - do actual merge
  def merge
    respond_to do |format|
      if request.method_symbol == :get
        format.html { render action: :merge }
      else
        if motion_merger.save
          format.html { redirect_to motion.terminal_merged_motion, notice: 'Motion merged.' }
          format.xml { head :ok }
        else
          format.html { redirect_to motion, alert: 'Cannot merge the motion.' }
          format.xml { render xml: motion.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # GET /motions/:id/refer
  # PUT /motions/:id/refer
  def refer
    respond_to do |format|
      if request.method_symbol == :get
        format.html { render action: :refer }
      else
        referred_motion
        if motion.refer
          format.html { redirect_to(referred_motion, notice: 'Motion referred.') }
          format.xml  { head :ok }
      else
          format.html { render action: "refer" }
          format.xml  { render xml: motion.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # GET /motions/:id/amend
  # PUT /motions/:id/amend
  def amend
    respond_to do |format|
      if request.method_symbol == :get
        format.html
      else
        amendment
        if params[:motion]
        end
        if motion.amend
          format.html { redirect_to(amendment, notice: 'Motion amended.') }
          format.xml  { head :ok }
        else
          format.html { render action: "amend" }
          format.xml  { render xml: amendment.errors, status: :unprocessable_entity }
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
        motion.assign_attributes params.require(:motion).permit( *Motion.permitted_attributes( :divide ) )
        motion.referred_motions.each { |m| m.committee = motion.committee; m.published = true; m.period = motion.period }
        if motion.divide
          format.html { redirect_to(motion, notice: 'Motion divided.') }
          format.xml  { head :ok }
        else
          format.html { render action: "divide" }
          format.xml  { render xml: motion.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PUT /motions/:id/adopt
  # GET /motions/:id/adopt
  def adopt
    respond_to do |format|
      if request.method_symbol == :get
        format.html { render action: :adopt }
      else
        motion.assign_attributes event_motion_attributes
        if motion.adopt
          format.html { redirect_to(motion, notice: 'Motion adopted.') }
          format.xml  { head :ok }
        else
          format.html { render action: :adopt }
          format.xml  { render xml: motion.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PUT /motions/:id/implement
  # GET /motions/:id/implement
  def implement
    respond_to do |format|
      if request.method_symbol == :get
        format.html { render action: :implement }
    else
        motion.assign_attributes event_motion_attributes
        if motion.implement
          format.html { redirect_to(motion, notice: 'Motion implemented.') }
          format.xml  { head :ok }
        else
          format.html { render action: :implement }
          format.xml  { render xml: motion.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PUT /motions/:id/reject
  # GET /motions/:id/reject
  def reject
    respond_to do |format|
      if request.method_symbol == :get
        format.html { render action: :reject }
      else
        motion.assign_attributes event_motion_attributes
        if motion.reject
          format.html { redirect_to(motion, notice: 'Motion rejected.') }
          format.xml  { head :ok }
        else
          format.html { render action: :reject }
          format.xml  { render xml: motion.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /motions/1
  # DELETE /motions/1.xml
  def destroy
    motion.destroy

    respond_to do |format|
      format.html { redirect_to committee_motions_url( motion.committee, notice: 'Motion destroyed.' ) }
      format.xml  { head :ok }
    end
  end
end

