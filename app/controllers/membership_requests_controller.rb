class MembershipRequestsController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index, :expired, :unexpired,
    :active, :inactive, :rejected ]
  before_filter :new_membership_request_from_params, :only => [ :new, :create ]
  filter_access_to :new, :create, :edit, :update, :destroy, :show, :reject,
    :do_reject, :reactivate, :attribute_check => true
  filter_access_to :index, :renewed, :unrenewed, :expired, :unexpired, :active,
    :inactive, :rejected do
    @user ? permitted_to!( :show, @user ) : permitted_to!( :index )
  end
  before_filter :setup_breadcrumbs

  # GET /position/:position_id/membership_requests
  # GET /position/:position_id/membership_requests.xml
  # GET /committee/:committee_id/membership_requests
  # GET /committee/:committee_id/membership_requests.xml
  # GET /user/:user_id/membership_requests
  # GET /user/:user_id/membership_requests.xml
  def index
    unless params[:format] == 'csv'
      @membership_requests = @membership_requests.page( params[:page] )
    end

    respond_to do |format|
      format.csv { index_csv }
      format.html { render :action => 'index' } # index.html.erb
      format.xml  { render :xml => @membership_requests }
    end
  end

  # GET /user/:user_id/membership_requests/active
  # GET /user/:user_id/membership_requests/active.xml
  def active
    @membership_requests = @membership_requests.active
    add_breadcrumb 'Active', polymorphic_path( [ :active, @context, :membership_requests ] )
    index
  end

  # GET /user/:user_id/membership_requests/inactive
  # GET /user/:user_id/membership_requests/inactive.xml
  def inactive
    @membership_requests = @membership_requests.inactive
    add_breadcrumb 'Inactive', polymorphic_path( [ :inactive, @context, :membership_requests ] )
    index
  end

  # GET /user/:user_id/membership_requests/rejected
  # GET /user/:user_id/membership_requests/rejected.xml
  def rejected
    @membership_requests = @membership_requests.rejected
    add_breadcrumb 'Rejected', polymorphic_path( [ :rejected, @context, :membership_requests ] )
    index
  end

  # GET /user/:user_id/membership_requests/expired
  # GET /user/:user_id/membership_requests/expired.xml
  def expired
    @membership_requests = @membership_requests.expired
    add_breadcrumb 'Expired', polymorphic_path( [ :expired, @context, :membership_requests ] )
    index
  end

  # GET /user/:user_id/membership_requests/unexpired
  # GET /user/:user_id/membership_requests/unexpired.xml
  def unexpired
    @membership_requests = @membership_requests.unexpired
    add_breadcrumb 'Unexpired', polymorphic_path( [ :unexpired, @context, :membership_requests ] )
    index
  end

  # GET /membership_requests/1
  # GET /membership_requests/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @membership_request }
    end
  end

  # GET /positions/:position_id/membership_requests/new
  # GET /positions/:position_id/membership_requests/new.xml
  # GET /committees/:committee_id/membership_requests/new
  # GET /committees/:committee_id/membership_requests/new.xml
  # GET /memberships/:membership_id/membership_requests/new
  # GET /memberships/:membership_id/membership_requests/new.xml
  def new
    @membership_request.answers.populate

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @membership_request }
    end
  end

  # GET /membership_requests/1/edit
  def edit
    @membership_request.answers.populate

    respond_to do |format|
      format.html { render :action => 'edit' }
    end
  end

  # POST /positions/:position_id/membership_requests
  # POST /positions/:position_id/membership_requests.xml
  # POST /committees/:committee_id/membership_requests
  # POST /committees/:committee_id/membership_requests.xml
  # POST /memberships/:membership_id/membership_requests
  # POST /memberships/:membership_id/membership_requests.xml
  def create
    respond_to do |format|
      if @membership_request.save
        flash[:notice] = 'Membership request was successfully created.'
        format.html { redirect_to(@membership_request) }
        format.xml  { render :xml => @membership_request, :status => :created, :location => @membership_request }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @membership_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /membership_requests/1
  # PUT /membership_requests/1.xml
  def update
    respond_to do |format|
      @membership_request.assign_attributes(params[:membership_request])
      if ( @membership_request.active? && @membership_request.save ) || @membership_request.reactivate
        flash[:notice] = 'Membership request was successfully updated.'
        format.html { redirect_to @membership_request }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @membership_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /membership_requests/:id/reject
  # PUT /membership_requests/:id/reject
  def reject
    respond_to do |format|
      if request.request_method_symbol == :put
        @membership_request.rejected_by_user = current_user
        @membership_request.assign_attributes params[:membership_request], as: :rejector
        if @membership_request.reject
          flash[:notice] = 'Membership request was successfully rejected.'
          format.html { redirect_to @membership_request }
          format.xml  { head :ok }
        else
          format.html { render :action => "reject" }
          format.xml  { render :xml => @membership_request.errors, :status => :unprocessable_entity }
        end
      else
        @membership_request.rejected_by_authority ||= ( current_user.authorities.authorized.to_a & @membership_request.authorities ).first
        format.html
      end
    end
  end

  # PUT /membership_requests/1/do_reject
  # PUT /membership_requests/1/do_reject.xml
  def do_reject
  end

  # PUT /membership_requests/1/reactivate
  # PUT /membership_requests/1/reactivate.xml
  def reactivate
    respond_to do |format|
      if @membership_request.reactivate
        flash[:notice] = 'Membership request was successfully reactivated.'
        format.html { redirect_to @membership_request }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @membership_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /membership_requests/1
  # DELETE /membership_requests/1.xml
  def destroy
    @membership_request.destroy

    respond_to do |format|
      format.html { redirect_to polymorphic_url( [ @membership_request.committee, :membership_requests ] ),
        notice: 'Membership request was successfully destroyed.' }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @membership_request = MembershipRequest.find( params[:id] ) if params[:id]
    @committee = @membership_request.committee if @membership_request
    @committee = Committee.find params[:committee_id] if params[:committee_id]
    @authority = Authority.find( params[:authority_id] ) if params[:authority_id]
    unless @membership_request || @authority
      @user = params[:user_id] ? User.find( params[:user_id] ) : current_user
    end
    if @committee
      @membership_request ||= @committee.membership_requests.where( user_id: @user.id ).first
    end
    @context = @authority || @committee || @user
  end

  def initialize_index
    @membership_requests = @context.membership_requests.ordered.with_permissions_to( :show )
    @title = "for #{@context}"
  end

  def new_membership_request_from_params
    if @membership_request && @membership_request.persisted?
      return redirect_to edit_membership_request_url( @membership_request )
    end
    @membership_request = @committee.membership_requests.build
    @membership_request.starts_at ||= @membership.starts_at if @membership
    @membership_request.user ||= ( @membership ? @membership.user : @user )
    @membership_request.assign_attributes params[:membership_request]
  end

  def setup_breadcrumbs
    if @context
      add_breadcrumb @context.class.to_s.pluralize,
        polymorphic_path( [ @context.class.arel_table.name ] )
      add_breadcrumb @context, polymorphic_path( [ @context ] )
    end
    add_breadcrumb "MembershipRequests", polymorphic_path( [ @context, :membership_requests ] )
    if @membership_request && @membership_request.persisted?
      add_breadcrumb @membership_request, membership_request_path( @membership_request )
    end
  end

  def index_csv
    csv_string = CSV.generate do |csv|
      csv << %w( net_id first last status committee until )
      @membership_requests.all.each do |membership_request|
        csv << [ membership_request.user.net_id, membership_request.user.first_name,
          membership_request.user.last_name, membership_request.user.status,
          membership_request.committee, membership_request.ends_at ]
      end
    end
    send_data csv_string, :disposition => "attachment; filename=membership_requests.csv",
      :type => :csv
  end

end

