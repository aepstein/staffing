class CommitteesController < ApplicationController
  before_filter :require_user, :initialize_context
  before_filter :new_committee_from_params, :only => [ :new, :create ]
  filter_access_to :new, :create, :edit, :update, :destroy, :show, :index,
    :tents, :members
  filter_access_to :requestable do
    permitted_to!( :show, @user )
  end
  before_filter :setup_breadcrumbs

  # GET /users/:user_id/committees/requestable
  # GET /users/:user_id/committees/requestable.xml
  def requestable
    @committees = @user.committees.requestable
    index
  end

  # GET /committees/:id/tents.pdf
  include UserTentReports
  def tents
    @context = @committee
    @users = User.joins(:memberships).merge( @committee.memberships.current )
    render_user_tent_reports
  end

  # GET /committees/:id/members.pdf
  def members
    respond_to do |format|
      format.pdf do
        report = MembershipReport.new(@committee)
        send_data report.to_pdf, :filename => "#{@committee.name :file}-members.pdf",
          :type => 'application/pdf', :disposition => 'inline'
      end
    end
  end

  # GET /committees
  # GET /committees.xml
  def index
    @committees ||= Committee.scoped
    @q = @committees.search( params[:term] ? { :name_cont => params[:term] } : params[:q] )
    @committees = @q.result.ordered.page( params[:page] )

    respond_to do |format|
      format.html { render :action => 'index' }
      format.json # index.json.erb
      format.xml  { render :xml => @committees }
    end
  end

  # GET /committees/1
  # GET /committees/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @committee }
    end
  end

  # GET /committees/new
  # GET /committees/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @committee }
    end
  end

  # GET /committees/1/edit
  def edit
  end

  # POST /committees
  # POST /committees.xml
  def create
    respond_to do |format|
      if @committee.save
        flash[:notice] = 'Committee was successfully created.'
        format.html { redirect_to(@committee) }
        format.xml  { render :xml => @committee, :status => :created, :location => @committee }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @committee.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /committees/1
  # PUT /committees/1.xml
  def update
    respond_to do |format|
      if @committee.update_attributes(params[:committee])
        flash[:notice] = 'Committee was successfully updated.'
        format.html { redirect_to(@committee) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @committee.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /committees/1
  # DELETE /committees/1.xml
  def destroy
    @committee.destroy

    respond_to do |format|
      format.html { redirect_to(committees_url) }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @committee = Committee.find params[:id] if params[:id]
    @user = User.find params[:user_id] if params[:user_id]
  end

  def new_committee_from_params
    @committee = Committee.new( params[:committee] )
  end

  def setup_breadcrumbs
    add_breadcrumb @user.name, user_path( @user ) if @user
    add_breadcrumb 'Committees', committees_path
    if @committee && @committee.persisted?
      add_breadcrumb @committee.name, committee_path( @committee )
    end
  end

end

