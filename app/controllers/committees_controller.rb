class CommitteesController < ApplicationController
  before_filter :require_user
  expose :as_of do
    begin
      if params[:as_of]
        return Date.parse( params[:as_of] )
      end
    rescue ArgumentError
      flash[:error] = 'Invalid date supplied for report.'
    end
    Time.zone.today
  end
  expose( :user ) { User.find params[:user_id] if params[:user_id] }
  expose :q_scope do
    scope = user.committees.requestable if params[:action] == 'requestable'
    scope ||= user.committees.scoped if user
    scope ||= Committee.scoped
  end
  expose :q do
    q_scope.search( params[:term] ? { name_cont: params[:term] } : params[:q] )
  end
  expose :committees do
    q.result.ordered.page(params[:page])
  end
  expose :committee
  filter_access_to :new, :create, :edit, :update, :destroy, :show, :index, load_method: :committee
  filter_access_to :tents, :members, require: :enroll, load_method: :committee
  filter_access_to :requestable, require: :show, load_method: :user

  def index
    respond_to do |format|
      format.html { render action: 'index' }
      format.json { render json: committees.map(&:name) }
    end
  end

  # GET /users/:user_id/committees/requestable
  # GET /users/:user_id/committees/requestable.xml
  def requestable
    index
  end

  # GET /committees/:id/tents.pdf
  include UserTentReports
  def tents
    render_user_tent_reports committee.memberships.tents( as_of )
  end

  # GET /committees/:id/members.pdf
  def members
    respond_to do |format|
      format.pdf do
        report = MembershipReport.new( committee, as_of )
        send_data report.to_pdf, filename: "#{committee.name :file}-members.pdf",
          type: 'application/pdf', disposition: 'inline'
      end
    end
  end

  # GET /committees/:id/emplids.pdf
  def empl_ids
    respond_to do |format|
      format.pdf do
        report = EmplIdReport.new( committee, as_of )
        send_data report.to_pdf, filename: "#{committee.name :file}-empl_ids.pdf",
          type: 'application/pdf', disposition: 'inline'
      end
    end
  end

  # POST /committees
  # POST /committees.xml
  def create
    respond_to do |format|
      if committee.save
        format.html { redirect_to(committee, flash: { success: "Committee created." }) }
        format.xml  { render xml: committee, status: :created, location: committee }
      else
        format.html { render action: "new" }
        format.xml  { render xml: committee.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /committees/1
  # PUT /committees/1.xml
  def update
    respond_to do |format|
      if committee.save
        format.html { redirect_to(committee, flash: { success: "Committee updated." }) }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: committee.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /committees/1
  # DELETE /committees/1.xml
  def destroy
    committee.destroy

    respond_to do |format|
      format.html { redirect_to(committees_url, flash: { success: "Committee destroyed." } ) }
      format.xml  { head :ok }
    end
  end
end

