class MembershipsController < ApplicationController
  before_filter :require_user, :initialize_context
  before_filter :new_membership_from_params, :only => [ :new, :create ]
  filter_access_to :new, :create, :edit, :update, :destroy, :show, :confirm, :attribute_check => true
  filter_access_to :assign do
    permitted_to! :edit, @membership
  end
  filter_access_to :index, :current, :past, :future do
    @user ? permitted_to!( :show, @user ) : permitted_to!( :index )
  end

  # GET /committees/:committee_id/memberships/renewed
  # GET /committees/:committee_id/memberships/renewed.xml
  # GET /users/:user_id/memberships/renewed
  # GET /users/:user_id/memberships/renewed.xml
  def renewed
    @memberships = @memberships.renewed if @memberships
    index
  end

  # GET /committees/:committee_id/memberships/unrenewed
  # GET /committees/:committee_id/memberships/unrenewed.xml
  # GET /users/:user_id/memberships/unrenewed
  # GET /users/:user_id/memberships/unrenewed.xml
  def unrenewed
    @memberships = @memberships.renewable.unrenewed if @memberships
    index
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

  # GET /requests/:request_id/memberships/assignable
  def assignable
    @memberships = @request.memberships.assignable
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
    if request.format == Mime::HTML
      @memberships = @search.paginate( :page => params[:page], :include => [ :request ] )
    else
      @memberships = @search.all( :include => [ :request ] )
    end

    respond_to do |format|
      format.html { render :action => 'index' }
      format.csv { csv_index }
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
    @membership.designees.populate

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @membership }
    end
  end

  # GET /memberships/1/edit
  def edit
    if @request
      @membership.starts_at, @membership.ends_at, @membership.request = nil, nil, @request
    end
    @membership.designees.populate
    respond_to do |format|
      format.html { render :action => 'edit' }
    end
  end

  # POST /positions/:position_id/memberships
  # POST /positions/:position_id/memberships.xml
  def create
    @membership.attributes = params[:membership]

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

  def confirm
    respond_to do |format|
      if @membership.confirm
        flash[:notice] = 'Membership settings confirmed.'
        format.html { redirect_to unrenewed_user_memberships_url @membership.user }
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
    @membership.destroy

    respond_to do |format|
      format.html { redirect_to position_memberships_url @membership.position }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
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
    @membership = Membership.find( params[:id] ) if params[:id]
  end

  def new_membership_from_params
    @membership = Membership.new(:request => @request) if @request
    @membership = @position.memberships.build if @position
  end

  def csv_index
    csv_string = StringIO.new
    CSV.generate csv_string do |csv|
      csv << ['user','netid','email','mobile','position','committee','title','vote','period','starts at','ends at','renew until?']
      @memberships.each do |membership|
        next unless permitted_to?( :show, membership )
        membership.enrollments.each do |enrollment|
          csv << ( [ membership.user.name,
                     membership.user.net_id,
                     membership.user.email,
                     membership.user.mobile_phone,
                     membership.position.name,
                     enrollment.committee.name,
                     enrollment.title,
                     enrollment.votes,
                     membership.period,
                     membership.starts_at,
                     membership.ends_at,
                     membership.renew_until ? membership.renew_until.to_formatted_s(:rfc822) : ""
          ] )
        end
      end
    end
    send_data csv_string, :disposition => "attachment; filename=memberships.csv"
  end

end

