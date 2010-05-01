class MembershipsController < ApplicationController
  before_filter :initialize_contexts
  filter_access_to :new, :create, :edit, :update, :destroy, :show, :index
  filter_access_to :current, :past, :future do
    permitted_to!( :show, @user ) || permitted_to!( :index )
  end

  def current
    @memberships = @request.memberships.current if @request
    @memberships = @position.memberships.current if @position
    @memberships = @committee.memberships.current if @committee
    @memberships = @user.memberships.current if @user
    index
  end

  def future
    @memberships = @request.memberships.future if @request
    @memberships = @position.memberships.future if @position
    @memberships = @committee.memberships.future if @committee
    @memberships = @user.memberships.future if @user
    index
  end

  def past
    @memberships = @request.memberships.past if @request
    @memberships = @position.memberships.past if @position
    @memberships = @committee.memberships.past if @committee
    @memberships = @user.memberships.past if @user
    index
  end

  # GET /positions/:position_id/memberships
  # GET /positions/:position_id/memberships.xml
  def index
    @memberships ||= @request.memberships if @request
    @memberships ||= @position.memberships if @position
    @memberships ||= @committee.memberships if @committee
    @memberships ||= @user.memberships if @user
    @memberships ||= Membership.all
    @memberships = @memberships.period_current if params[:current_period]
    @memberships = @memberships.current if params[:current]
    @memberships = @memberships.paginate(:page => params[:page])

    respond_to do |format|
      format.html { render :action => 'index' }
      format.xml  { render :xml => @memberships }
    end
  end

  # GET /memberships/1
  # GET /memberships/1.xml
  def show
    @membership = Membership.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @membership }
    end
  end

  # GET /positions/:position_id/memberships/new
  # GET /positions/:position_id/memberships/new.xml
  def new
    if @request
      @membership = Membership.new(:request => @request)
    end
    if @position
      @membership = @position.memberships.build
    end
    @membership.designees.populate

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @membership }
    end
  end

  # GET /memberships/1/edit
  def edit
    @membership = Membership.find(params[:id])
    @membership.designees.populate
  end

  # POST /positions/:position_id/memberships
  # POST /positions/:position_id/memberships.xml
  def create
    if @request
      @membership = Membership.new(:request => @request)
      @membership.attributes = params[:membership]
    end
    if @position
      @membership = @position.memberships.build( params[:membership] )
    end

    respond_to do |format|
      if @membership.save
        flash[:notice] = 'Membership was successfully created.'
        format.html { redirect_to(@membership) }
        format.xml  { render :xml => @membership, :status => :created, :location => @membership }
      else
        @membership.designees.populate
        format.html { render :action => "new" }
        format.xml  { render :xml => @membership.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /memberships/1
  # PUT /memberships/1.xml
  def update
    @membership = Membership.find(params[:id])

    respond_to do |format|
      if @membership.update_attributes(params[:membership])
        flash[:notice] = 'Membership was successfully updated.'
        format.html { redirect_to(@membership) }
        format.xml  { head :ok }
      else
        @membership.designees.populate
        format.html { render :action => "edit" }
        format.xml  { render :xml => @membership.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /memberships/1
  # DELETE /memberships/1.xml
  def destroy
    @membership = Membership.find(params[:id])
    @membership.destroy

    respond_to do |format|
      format.html { redirect_to position_memberships_url @membership.position }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_contexts
    @request = Request.find params[:request_id] if params[:request_id]
    @position = Position.find params[:position_id] if params[:position_id]
    @committee = Committee.find params[:committee_id] if params[:committee_id]
    @user = User.find params[:user_id] if params[:user_id]
  end
end

