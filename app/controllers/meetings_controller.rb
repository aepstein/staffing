class MeetingsController < ApplicationController
  expose :starts_at do
    if params[:start] && ( sanitized = params[:start].to_i ) > 0
      Time.zone.at sanitized
    else
      nil
    end
  end
  expose :ends_at do
    if params[:end] && ( sanitized = params[:end].to_i ) > 0
      Time.zone.at sanitized
    else
      nil
    end
  end
  expose( :committee ) { Committee.find params[:committee_id] if params[:committee_id] }
  expose( :motion ) { Motion.find params[:motion_id] if params[:motion_id] }
  expose :q_scope do
    scope ||= committee.meetings if committee
    scope ||= motion.meetings if motion
    scope ||= Meeting.scoped
    scope = scope.past if params[:action] == 'past'
    scope = scope.current if params[:action] == 'current'
    scope = scope.future if params[:action] == 'future'
    scope = scope.where { starts_at.gte( starts_at ) } if starts_at
    scope = scope.where { starts_at.lte( ends_at ) } if ends_at
    scope
  end
  expose( :q ) { q_scope.search( params[:q] ) }
  expose :meetings do
    q.result.with_permissions_to(:show).ordered.page(params[:page])
  end
  expose :meeting do
    out = if params[:id]
      Meeting.find params[:id]
    else
      return nil unless committee
      committee.meetings.build
    end
    out.period ||= out.committee.schedule.periods.current.first if out.new_record?
    out
  end
  expose( :role ) { permitted_to?(:staff, meeting) ? :staff : :default }
  before_filter( only: [ :create, :update ] ) { meeting.assign_attributes params[:meeting], as: role }
  before_filter :populate_meeting_sections, only: [ :new, :edit ]
  before_filter :reciprocate_attachments, only: [ :create, :update ]
  filter_access_to :new, :create, :edit, :update, :destroy, :show, :publish,
    attribute_check: true, load_method: :meeting
  filter_access_to :editable_minutes, :published_minutes, :audio, :agenda,
    attribute_check: true, require: :show, load_method: :meeting

  # GET /meetings/:id/agenda.pdf
  def agenda
    respond_to do |format|
      format.pdf do
        report = MeetingAgendaReport.new( meeting )
        send_data report.to_pdf, filename: "#{meeting.to_s :file}-agenda.pdf",
          type: 'application/pdf', disposition: 'inline'
      end
    end
  end

  # GET /meetings/:id/publish
  # PUT /meetings/:id/publish
  def publish
    respond_to do |format|
      if request.method_symbol == :get
        meeting.publish_defaults
        format.html { render action: :publish }
      else
        meeting.assign_attributes params[:meeting], as: :publisher
        meeting.publish_from = current_user.email
        if meeting.publish
          format.html { redirect_to( meeting, flash: { success: 'Meeting published.' } ) }
          format.xml  { head :ok }
        else
          format.html { render action: :publish, flash: { error: 'You must specify a recipient.' } }
          format.xml  { render xml: meeting.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # GET /meetings/:id/editable_minutes.(doc|odt|tex|txt)
  def editable_minutes
    send_file meeting.editable_minutes.current_path,
      filename: meeting.to_s(:editable_minutes_file),
      content_type: meeting.editable_minutes.content_type,
      disposition: 'attachment'
  end

  # GET /meetings/current
  # GET /meetings/current.xml
  # GET /committees/:committee_id/meetings/current
  # GET /committees/:committee_id/meetings/current.xml
  # GET /motions/:motion_id/meetings/current
  # GET /motions/:motion_id/meetings/current.xml
  def current
    index
  end

  # GET /meetings/past
  # GET /meetings/past.xml
  # GET /committees/:committee_id/meetings/past
  # GET /committees/:committee_id/meetings/past.xml
  # GET /motions/:motion_id/meetings/past
  # GET /motions/:motion_id/meetings/past.xml
  def past
    index
  end

  # GET /meetings/future
  # GET /meetings/future.xml
  # GET /committees/:committee_id/meetings/future
  # GET /committees/:committee_id/meetings/future.xml
  # GET /motions/:motion_id/meetings/future
  # GET /motions/:motion_id/meetings/future.xml
  def future
    index
  end

  # GET /committees/:committee_id/meetings
  # GET /committees/:committee_id/meetings.xml
  # GET /motions/:motion_id/meetings
  # GET /motions/:motion_id/meetings.xml
  def index
    respond_to do |format|
      format.html { render action: 'index' } # index.html.erb
      format.json { render json: meetings.per(500).map(&:to_json_attributes) }
      format.xml  { render xml: meetings }
    end
  end

  # POST /committees/:committee_id/meetings
  # POST /committees/:committee_id/meetings.xml
  def create
    respond_to do |format|
      if meeting.save
        format.html { redirect_to( meeting, flash: { success: 'Meeting created.' } ) }
        format.xml  { render xml: meeting, status: :created, location: meeting }
      else
        format.html { render action: "new" }
        format.xml  { render xml: meeting.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /meetings/1
  # PUT /meetings/1.xml
  def update
    respond_to do |format|
      if meeting.save
        format.html { redirect_to meeting, flash: { success: 'Meeting updated.' } }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: meeting.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /meetings/1
  # DELETE /meetings/1.xml
  def destroy
    meeting.destroy

    respond_to do |format|
      format.html { redirect_to( committee_meetings_url( meeting.committee ),
        flash: { success: "Meeting destroyed." } ) }
      format.xml  { head :ok }
    end
  end

  private

  def populate_meeting_sections
    meeting.meeting_sections.populate
  end

  def reciprocate_attachments
    meeting.meeting_sections.each do |section|
      section.meeting_items.each do |item|
        item.attachments.each { |attachment| attachment.attachable = item }
      end
    end
  end
end

