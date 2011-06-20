class MembershipsController < ApplicationController
  before_filter :require_user, :initialize_context
  before_filter :initialize_index, :only => [ :index, :renewed, :unrenewed,
    :current, :future, :past, :assignable ]
  before_filter :new_membership_from_params, :only => [ :new, :create ]
  filter_access_to :new, :create, :edit, :update, :destroy, :show, :confirm,
    :attribute_check => true
  filter_access_to :assign do
    permitted_to! :edit, @membership
  end
  filter_access_to :index, :current, :past, :future do
    @user ? permitted_to!( :show, @user ) : permitted_to!( :index )
  end
  before_filter :setup_breadcrumbs

  # GET /users/:user_id/memberships/renew
  # PUT /users/:user_id/memberships/renew
  def renew
    unless request.request_method_symbol == :get
      if @user.update_attributes( params[:user] )
        flash[:notice] = 'Renewal preferences successfully updated.'
      end
    end

    respond_to do |format|
      format.html
    end
  end

  # GET /committees/:committee_id/memberships/renewed
  # GET /committees/:committee_id/memberships/renewed.xml
  # GET /users/:user_id/memberships/renewed
  # GET /users/:user_id/memberships/renewed.xml
  def renewed
    @memberships = @memberships.renewed
    add_breadcrumb "Renewed",
      polymorphic_path( [ :renewed, @context, :memberships ] )
    index
  end

  # GET /committees/:committee_id/memberships/unrenewed
  # GET /committees/:committee_id/memberships/unrenewed.xml
  # GET /users/:user_id/memberships/unrenewed
  # GET /users/:user_id/memberships/unrenewed.xml
  def unrenewed
    @memberships = @memberships.renewable.unrenewed
    add_breadcrumb "Unrenewed",
      polymorphic_path( [ :unrenewed, @context, :memberships ] )
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
    @memberships = @memberships.current
    add_breadcrumb "Current",
      polymorphic_path( [ :current, @context, :memberships ] )
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
    @memberships = @memberships.future
    add_breadcrumb "Future",
      polymorphic_path( [ :future, @context, :memberships ] )
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
    @memberships = @memberships.past
    add_breadcrumb "Past",
      polymorphic_path( [ :past, @context, :memberships ] )
    index
  end

  # GET /requests/:request_id/memberships/assignable
  def assignable
    @memberships = @request.memberships.assignable
    add_breadcrumb "Assignable",
      polymorphic_path( [ :assignable, @context, :memberships ] )
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
    @search = @memberships.ordered.search( params[:search] )
    @memberships = @search.paginate( :page => params[:page], :include => [ :request ] )

    respond_to do |format|
      format.html { render :action => 'index' }
      format.csv { csv_index }
      format.pdf { pdf_index }
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
    unless @request.blank?
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
    @membership.accessible = Membership::UPDATABLE_ATTRIBUTES
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
    @membership.destroy

    respond_to do |format|
      format.html { redirect_to position_memberships_url @membership.position }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @membership = Membership.find( params[:id], :include => :designees ) if params[:id]
    @committee = Committee.find params[:committee_id] if params[:committee_id]
    @user = User.find params[:user_id] if params[:user_id]
    @position = Position.find params[:position_id] if params[:position_id]
    @authority = Authority.find params[:authority_id] if params[:authority_id]
    @request = Request.find params[:request_id] if params[:request_id]
    if @request
      @user = @request.user
    end
    if @membership && @membership.persisted?
      @user ||= @membership.user
      @request ||= @membership.request
      @position ||= @membership.position
      @authority ||= @position.authority
    end
    @context = @position || @authority || @committee || @user
  end

  def initialize_index
    @memberships = @context.memberships
  end

  def setup_breadcrumbs
    if @context
      add_breadcrumb @context.class.arel_table.name.titleize,
        polymorphic_path( [ @context.class.arel_table.name ] )
      add_breadcrumb @context, polymorphic_path( [ @context ] )
    end
    add_breadcrumb "Memberships", polymorphic_path( [ @context, :memberships ] )
    if @membership && @membership.persisted?
      add_breadcrumb @membership.tense.to_s.capitalize,
        polymorphic_path( [ @membership.tense, @context, :memberships ] )
      add_breadcrumb @membership, membership_path( @membership )
    end
  end

  def new_membership_from_params
    if @request
      @membership = Membership.new
      @membership.request = @request
    else
      @membership = @position.memberships.build
    end
    @membership.accessible = Membership::UPDATABLE_ATTRIBUTES
    @membership.attributes = params[:membership] if params[:membership]
    @membership.period ||= @membership.position.schedule.periods.active
    @membership.period ||= @membership.position.schedule.periods.first
    if @membership.period
      @membership.starts_at ||= @membership.period.starts_at
      @membership.ends_at ||= @membership.period.ends_at
    end
  end

  def csv_index
    csv_string = ""
    CSV.generate csv_string do |csv|
      csv << ['user','netid','email','mobile','position','committee','title','vote','period','starts at','ends at','renew until?']
      @search.all(:include => [ :request ]).each do |membership|
        next unless permitted_to?( :show, membership )
        membership.enrollments.each do |enrollment|
          next if @committee && (enrollment.committee_id != @committee.id)
          csv << ( [ membership.user_id? ? membership.user.name : '',
                     membership.user_id? ? membership.user.net_id : '',
                     membership.user_id? ? membership.user.email : '',
                     membership.user_id? ? membership.user.mobile_phone : '',
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

  def pdf_index
    report = MembershipReport.new(@memberships)
    send_data report.to_pdf, :filename => "memberships.pdf",
      :type => 'application/pdf', :disposition => 'inline'
  end

end

