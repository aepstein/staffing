class CommitteesController < ApplicationController
  before_filter :require_user, :initialize_context, :setup_breadcrumbs
  filter_access_to :new, :create, :edit, :update, :destroy, :show, :index
  filter_access_to :requestable do
    permitted_to!( :show, @user )
  end

  # GET /users/:user_id/committees/requestable
  # GET /users/:user_id/committees/requestable.xml
  def requestable
    @committees = @user.requestable_committees
    index
  end

  # GET /committees/:id/tents.pdf
  include UserTentReports
  def tents
    @users = User.joins(:memberships).merge( @committee.memberships.current )
    render_user_tent_reports
  end

  # GET /committees
  # GET /committees.xml
  def index
    @committees ||= Committee.scoped
    @search = @committees.search( params[:term] ? { :name_contains => params[:term] } : params[:search] )
    @committees = @search.paginate( :page => params[:page] )

    respond_to do |format|
      format.html { render :action => 'index' }
      format.json # index.json.erb
      format.xml  { render :xml => @committees }
    end
  end

  # GET /committees/1
  # GET /committees/1.xml
  def show
    @committee = Committee.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @committee }
    end
  end

  # GET /committees/new
  # GET /committees/new.xml
  def new
    @committee = Committee.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @committee }
    end
  end

  # GET /committees/1/edit
  def edit
    @committee = Committee.find(params[:id])
  end

  # POST /committees
  # POST /committees.xml
  def create
    @committee = Committee.new(params[:committee])

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
    @committee = Committee.find(params[:id])

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
    @committee = Committee.find(params[:id])
    @committee.destroy

    respond_to do |format|
      format.html { redirect_to(committees_url) }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @user = User.find params[:user_id] if params[:user_id]
  end

  def setup_breadcrumbs
    add_breadcrumb @user.name, user_path( @user ) if @user
    add_breadcrumb 'Committees', committees_path
    if @committee && @committee.persisted?
      add_breadcrumb @committee.name, committee_path( @committee )
    end
  end

end

