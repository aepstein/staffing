class RequestsController < ApplicationController
  before_filter :require_user, :initialize_context
  before_filter :initialize_requestable, :only => [ :index, :expired, :unexpired, :new, :create ]
  before_filter :new_request_from_params, :only => [ :new, :create ]
  filter_access_to :new, :create, :edit, :update, :destroy, :show, :attribute_check => true
  filter_access_to :index, :renewed, :unrenewed, :expired, :unexpired do
    @user ? permitted_to!( :show, @user ) : permitted_to!( :index )
  end

  # GET /position/:position_id/requests
  # GET /position/:position_id/requests.xml
  # GET /committee/:committee_id/requests
  # GET /committee/:committee_id/requests.xml
  # GET /user/:user_id/requests
  # GET /user/:user_id/requests.xml
  def index
    initialize_index unless @requests
    @requests = @requests.paginate( :page => params[:page] )

    respond_to do |format|
      format.html { render :action => 'index' } # index.html.erb
      format.xml  { render :xml => @requests }
    end
  end

  # GET /user/:user_id/requests/expired
  # GET /user/:user_id/requests/expired.xml
  def expired
    initialize_index
    @requests = @requests.expired
    return index
  end

  # GET /user/:user_id/requests/unexpired
  # GET /user/:user_id/requests/unexpired.xml
  def unexpired
    initialize_index
    @requests = @requests.unexpired
    return index
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
      if @request.update_attributes(params[:request])
        flash[:notice] = 'Request was successfully updated.'
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

  def initialize_index
    if @requestable
      @requests = @requestable.requests.with_permissions_to( :show )
      @title = "for #{@requestable}"
    elsif @authority
      @requests = @authority.requests.with_permissions_to( :show )
      @title = "for #{@authority}"
    else
      @requests = @user.requests.with_permissions_to( :show )
      @title = "for #{@user}"
    end
  end

  def initialize_context
    @request = Request.find( params[:id] ) if params[:id]
    @authority = Authority.find( params[:authority_id] ) if params[:authority_id]
    unless @request || @authority
      @user = params[:user_id] ? User.find( params[:user_id] ) : current_user
    end
  end

  def initialize_requestable
    @requestable = Position.find params[:position_id] if params[:position_id]
    @requestable = Committee.find params[:committee_id] if params[:committee_id]
    if params[:membership_id]
      @membership = Membership.find params[:membership_id]
      @user = @membership.user
      @request ||= @membership.request
      @membership.position.requestables.each do |requestable|
        @request ||= @membership.user.requests.first( :conditions =>
          { :requestable_type => requestable.class.to_s,
            :requestable_id => requestable.id } )
      end
      @requestable ||= @request.requestable if @request
      @requestable ||= @membership.position.requestables.first unless @membership.position.requestables.empty?
    end
    return unless @requestable
    @request ||= @requestable.requests.first( :conditions => { :user_id => @user } )
  end

  def new_request_from_params
    return redirect_to edit_request_url( @request ) unless @request.nil? || @request.new_record?
    @request = @requestable.requests.build( params[:request] )
    @request.user ||= ( @membership ? @membership.user : @user )
  end

end

