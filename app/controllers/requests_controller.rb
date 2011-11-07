class RequestsController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index, :expired, :unexpired,
    :active, :inactive, :rejected ]
  before_filter :new_request_from_params, :only => [ :new, :create ]
  filter_access_to :new, :create, :edit, :update, :destroy, :show, :reject,
    :do_reject, :reactivate, :attribute_check => true
  filter_access_to :index, :renewed, :unrenewed, :expired, :unexpired, :active,
    :inactive, :rejected do
    @user ? permitted_to!( :show, @user ) : permitted_to!( :index )
  end
  before_filter :setup_breadcrumbs

  # GET /position/:position_id/requests
  # GET /position/:position_id/requests.xml
  # GET /committee/:committee_id/requests
  # GET /committee/:committee_id/requests.xml
  # GET /user/:user_id/requests
  # GET /user/:user_id/requests.xml
  def index
    unless params[:format] == 'csv'
      @requests = @requests.page( params[:page] )
    end

    respond_to do |format|
      format.csv { index_csv }
      format.html { render :action => 'index' } # index.html.erb
      format.xml  { render :xml => @requests }
    end
  end

  # GET /user/:user_id/requests/active
  # GET /user/:user_id/requests/active.xml
  def active
    @requests = @requests.active
    add_breadcrumb 'Active', polymorphic_path( [ :active, @context, :requests ] )
    index
  end

  # GET /user/:user_id/requests/inactive
  # GET /user/:user_id/requests/inactive.xml
  def inactive
    @requests = @requests.inactive
    add_breadcrumb 'Inactive', polymorphic_path( [ :inactive, @context, :requests ] )
    index
  end

  # GET /user/:user_id/requests/rejected
  # GET /user/:user_id/requests/rejected.xml
  def rejected
    @requests = @requests.rejected
    add_breadcrumb 'Rejected', polymorphic_path( [ :rejected, @context, :requests ] )
    index
  end

  # GET /user/:user_id/requests/expired
  # GET /user/:user_id/requests/expired.xml
  def expired
    @requests = @requests.expired
    add_breadcrumb 'Expired', polymorphic_path( [ :expired, @context, :requests ] )
    index
  end

  # GET /user/:user_id/requests/unexpired
  # GET /user/:user_id/requests/unexpired.xml
  def unexpired
    @requests = @requests.unexpired
    add_breadcrumb 'Unexpired', polymorphic_path( [ :unexpired, @context, :requests ] )
    index
  end

  # GET /requests/1
  # GET /requests/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @request }
    end
  end

  # GET /positions/:position_id/requests/new
  # GET /positions/:position_id/requests/new.xml
  # GET /committees/:committee_id/requests/new
  # GET /committees/:committee_id/requests/new.xml
  # GET /memberships/:membership_id/requests/new
  # GET /memberships/:membership_id/requests/new.xml
  def new
    @request.answers.populate

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @request }
    end
  end

  # GET /requests/1/edit
  def edit
    @request.answers.populate

    respond_to do |format|
      format.html { render :action => 'edit' }
    end
  end

  # POST /positions/:position_id/requests
  # POST /positions/:position_id/requests.xml
  # POST /committees/:committee_id/requests
  # POST /committees/:committee_id/requests.xml
  # POST /memberships/:membership_id/requests
  # POST /memberships/:membership_id/requests.xml
  def create
    respond_to do |format|
      if @request.save
        flash[:notice] = 'Request was successfully created.'
        format.html { redirect_to(@request) }
        format.xml  { render :xml => @request, :status => :created, :location => @request }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /requests/1
  # PUT /requests/1.xml
  def update
    respond_to do |format|
      @request.assign_attributes(params[:request])
      if ( @request.active? && @request.save ) || @request.reactivate
        flash[:notice] = 'Request was successfully updated.'
        format.html { redirect_to @request }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /requests/1/reject
  def reject
    @request.rejected_by_authority ||= ( current_user.authorities.authorized.to_a & @request.authorities ).first
    return
  end

  # PUT /requests/1/do_reject
  # PUT /requests/1/do_reject.xml
  def do_reject
    @request.rejected_by_user = current_user
    @request.assign_attributes params[:request], as: :rejector
    respond_to do |format|
      if @request.reject
        flash[:notice] = 'Request was successfully rejected.'
        format.html { redirect_to @request }
        format.xml  { head :ok }
      else
        format.html { render :action => "reject" }
        format.xml  { render :xml => @request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /requests/1/reactivate
  # PUT /requests/1/reactivate.xml
  def reactivate
    respond_to do |format|
      if @request.reactivate
        flash[:notice] = 'Request was successfully reactivated.'
        format.html { redirect_to @request }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /requests/1
  # DELETE /requests/1.xml
  def destroy
    @request.destroy

    respond_to do |format|
      format.html { redirect_to polymorphic_url( [ @request.requestable, :requests ] ) }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @request = Request.find( params[:id] ) if params[:id]
    @requestable = @request.requestable if @request
    @requestable = Position.find params[:position_id] if params[:position_id]
    @requestable = Committee.find params[:committee_id] if params[:committee_id]
    @authority = Authority.find( params[:authority_id] ) if params[:authority_id]
    unless @request || @authority
      @user = params[:user_id] ? User.find( params[:user_id] ) : current_user
    end
    if @requestable
      @request ||= @requestable.requests.where( :user_id => @user.id ).first
    end
    @context = @authority || @requestable || @user
  end

  def initialize_index
    @requests = @context.requests.ordered.with_permissions_to( :show )
    @title = "for #{@context}"
  end

  def new_request_from_params
    if @request && @request.persisted?
      return redirect_to edit_request_url( @request )
    end
    @request = @requestable.requests.build
    @request.starts_at ||= @membership.starts_at if @membership
    @request.user ||= ( @membership ? @membership.user : @user )
    @request.assign_attributes params[:request]
  end

  def setup_breadcrumbs
    if @context
      add_breadcrumb @context.class.to_s.pluralize,
        polymorphic_path( [ @context.class.arel_table.name ] )
      add_breadcrumb @context, polymorphic_path( [ @context ] )
    end
    add_breadcrumb "Requests", polymorphic_path( [ @context, :requests ] )
    if @request && @request.persisted?
      add_breadcrumb @request, request_path( @request )
    end
  end

  def index_csv
    csv_string = CSV.generate do |csv|
      csv << %w( net_id first last status requestable until )
      @requests.all.each do |request|
        csv << [ request.user.net_id, request.user.first_name,
          request.user.last_name, request.user.status,
          request.requestable, request.ends_at ]
      end
    end
    send_data csv_string, :disposition => "attachment; filename=requests.csv",
      :type => :csv
  end

end

