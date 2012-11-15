class MembershipsController < ApplicationController
  before_filter :require_user, :initialize_context
  before_filter :initialize_index, only: [ :index, :renewed, :unrenewed,
    :current, :future, :past, :assignable, :renewable ]
  before_filter :new_membership_from_params, only: [ :new, :create ]
  before_filter :set_modifier, only: [ :create, :update ]
  filter_access_to :new, :create, :edit, :update, :destroy, :show, :confirm,
    :decline, attribute_check: true
  filter_access_to :renew do
    permitted_to! :update, @user
  end

  # GET /memberships/:membership_id/decline
  # PUT /memberships/:membership_id/decline
  def decline
    respond_to do |format|
      if request.request_method_symbol == :put
        if @membership.decline_renewal( params[:membership], user: current_user )
          format.html { redirect_to @membership, notice: 'Membership renewal was successfully declined.' }
          format.xml  { head :ok }
        else
          format.html
          format.xml  { render xml: @membership.errors, status: :unprocessable_entity }
        end
      else
        format.html
      end
    end
  end

  # GET /authorities/:authority_id/memberships/renewable
  def renewable
    @memberships = @memberships.renewal_candidate.renewal_undeclined.renew_until(Time.zone.today)
    add_breadcrumb "Renewable",
      polymorphic_path( [ :renewable, @context, :memberships ] )
    index
  end

  # GET /users/:user_id/memberships/renew
  # PUT /users/:user_id/memberships/renew
  def renew
    unless request.request_method_symbol == :get
      if @user.update_attributes( params[:user], as: :default )
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
    @q = @memberships.search( params[:q] )
    @memberships = @q.result.page( params[:page] )

    respond_to do |format|
      format.html { render :action => 'index' }
      format.csv { csv_index }
      format.xml  { render :xml => @memberships }
    end
  end

  # GET /memberships/1
  # GET /memberships/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @membership }
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
    @membership.designees.populate
    respond_to do |format|
      format.html { render action: 'edit' }
    end
  end

  # POST /positions/:position_id/memberships
  # POST /positions/:position_id/memberships.xml
  def create
    respond_to do |format|
      if @membership.save
        format.html { redirect_to(@membership, notice: 'Membership was successfully created.') }
        format.xml  { render xml: @membership, status: :created, location: @membership }
      else
        @membership.designees.populate
        format.html { render action: "new" }
        format.xml  { render xml: @membership.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /memberships/1
  # PUT /memberships/1.xml
  def update
    respond_to do |format|
      if @membership.update_attributes(params[:membership], as: :updator)
        format.html { redirect_to(@membership, notice: 'Membership was successfully updated.' ) }
        format.xml  { head :ok }
      else
        @membership.designees.populate
        format.html { render :action => "edit" }
        format.xml  { render :xml => @membership.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /memberships/1
  # DELETE /memberships/1.xml
  def destroy
    @membership.destroy

    respond_to do |format|
      format.html { redirect_to position_memberships_url(@membership.position),
        notice: "Membership was successfully destroyed." }
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
    @memberships = @context.memberships.ordered
    @memberships = @memberships.joins { position }.
      order { positions.name } unless @position
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
    @membership = @position.memberships.build_for_authorization
    @membership.assign_attributes params[:membership], as: :creator if params[:membership]
    @membership
  end

  def set_modifier
    unless permitted_to? :staff, @membership
      @membership.modifier = current_user
    end
    @membership
  end

  def csv_index
    csv_string = ""
    CSV.generate csv_string do |csv|
      csv << [ 'first', 'last','netid','email','mobile','position','committee',
        'title','vote','period','starts at','ends at','renew until?' ]
      @q.result.all(:include => [ :request ]).each do |membership|
        next unless permitted_to?( :show, membership )
        membership.enrollments.each do |enrollment|
          next if @committee && (enrollment.committee_id != @committee.id)
          csv << ( [ membership.user_id? ? membership.user.first_name : '',
                     membership.user_id? ? membership.user.last_name : '',
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
    send_data csv_string, :disposition => "attachment; filename=memberships.csv",
      :type => :csv
  end

end

