class MembershipsController < ApplicationController
  before_filter :require_user, :initialize_contexts
  filter_access_to :new, :create, :edit, :update, :destroy, :show
  filter_access_to :index, :current, :past, :future do
    @user ? permitted_to!( :show, @user ) : permitted_to!( :index )
  end

  # GET /committees/:committee_id/memberships/renewed
  # GET /committees/:committee_id/memberships/renewed.xml
  # GET /users/:user_id/memberships/renewed
  # GET /users/:user_id/memberships/renewed.xml
  def renewed
    @memberships = @memberships.renewed if @memberships
  end

  # GET /committees/:committee_id/memberships/unrenewed
  # GET /committees/:committee_id/memberships/unrenewed.xml
  # GET /users/:user_id/memberships/unrenewed
  # GET /users/:user_id/memberships/unrenewed.xml
  def unrenewed
    @memberships = @memberships.renewable.unrenewed if @memberships
  end

  # GET /requests/:request_id/memberships/current
  # GET /requests/:request_id/memberships/current.xml
  # GET /positions/:position_id/memberships/current
  # GET /positions/:position_id/memberships/current.xml
  # GET /committees/:committee_id/memberships/current
  # GET /committees/:committee_id/memberships/current.xml
  # GET /users/:user_id/memberships/current
  # GET /users/:user_id/memberships/current.xml
  # GET /authorities/:authority_id/memberships/current
  # GET /authorities/:authority_id/memberships/current.xml
  def current
    @memberships = @memberships.current if @memberships
    index
  end

  # GET /requests/:request_id/memberships/future
  # GET /requests/:request_id/memberships/future.xml
  # GET /positions/:position_id/memberships/future
  # GET /positions/:position_id/memberships/future.xml
  # GET /committees/:committee_id/memberships/future
  # GET /committees/:committee_id/memberships/future.xml
  # GET /users/:user_id/memberships/future
  # GET /users/:user_id/memberships/future.xml
  # GET /authorities/:authority_id/memberships/future
  # GET /authorities/:authority_id/memberships/future.xml
  def future
    @memberships = @memberships.future if @memberships
    index
  end

  # GET /requests/:request_id/memberships/past
  # GET /requests/:request_id/memberships/past.xml
  # GET /positions/:position_id/memberships/past
  # GET /positions/:position_id/memberships/past.xml
  # GET /committees/:committee_id/memberships/past
  # GET /committees/:committee_id/memberships/past.xml
  # GET /users/:user_id/memberships/past
  # GET /users/:user_id/memberships/past.xml
  # GET /authorities/:authority_id/memberships/past
  # GET /authorities/:authority_id/memberships/past.xml
  def past
    @memberships = @memberships.past if @memberships
    index
  end

  # GET /requests/:request_id/memberships
  # GET /requests/:request_id/memberships.xml
  # GET /positions/:position_id/memberships
  # GET /positions/:position_id/memberships.xml
  # GET /committees/:committee_id/memberships
  # GET /committees/:committee_id/memberships.xml
  # GET /users/:user_id/memberships
  # GET /users/:user_id/memberships.xml
  # GET /authorities/:authority_id/memberships
  # GET /authorities/:authority_id/memberships.xml
  def index
    @search = @memberships ? @memberships.search( params[:search] ) : Membership.with_user.search( params[:search] )
    @memberships = @search.paginate( :page => params[:page] )

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
    if params[:user_id]
      @user = User.find params[:user_id]
      @memberships = @user.memberships
    end
    if params[:request_id]
      @request = Request.find params[:request_id]
      @memberships = @request.memberships
    end
    if params[:position_id]
      @position = Position.find params[:position_id]
      @memberships = @position.memberships
    end
    if params[:committee_id]
      @committee = Committee.find params[:committee_id]
      @memberships = @committee.memberships
    end
    if params[:authority_id]
      @authority = Authority.find params[:authority_id]
      @memberships = @authority.memberships
    end
  end
end

