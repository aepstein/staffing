class MembershipsController < ApplicationController
  before_filter :require_user
  before_filter :populate_designees, only: [ :new, :edit ]
  expose( :position ) { Position.find params[:position_id] if params[:position_id] }
  expose( :committee ) { Committee.find params[:committee_id] if params[:committee_id] }
  expose( :user ) { User.find params[:user_id] if params[:user_id] }
  expose( :authority ) { Authority.find params[:authority_id] if params[:authority_id] }
  expose( :membership_request ) { MembershipRequest.find params[:membership_request_id] if params[:membership_request_id] }
  expose( :context ) { position || committee || user || authority || membership_request }
  expose :q_scope do
    scope = context.memberships.scoped if context
    scope = current_user.reviewable_memberships if params[:review]
    scope ||= Membership.scoped
    scope = case params[:action]
    when 'renewable'
      scope.renewal_candidate.renewal_undeclined.renew_until( Time.zone.today )
    when 'unrenewed'
      scope.renewable.unrenewed
    when 'renewed','current','past','future', 'active'
      scope.send params[:action]
    when 'active'
      scope.send 'current_or_future'
    when 'assignable'
      membership_request.memberships.assignable
    else
      scope
    end
  end
  expose( :q ) { q_scope.search params[:q] }
  expose( :memberships ) { q.result.ordered.page params[:page] }
  expose( :renew_user_memberships_attributes ) do
    params.require(:user).permit( :id, :renewal_checkpoint,
      { memberships_attributes: [ :id, :renew_until, :renewal_confirmed_at ] } )
  end
  expose( :decline_membership_attributes ) do
    params.require(:membership).permit( :decline_comment )
  end
  expose( :membership_attributes ) do
    params.require(:membership).permit( :user_name, :user_id, :period_id,
      :position_id, :membership_request_id, :starts_at, :ends_at, {
        designees_attributes: Designee::PERMITTED_ATTRIBUTES } )
  end
  expose :membership do
    out = if params[:id]
      Membership.find params[:id]
    else
      position.memberships.build_for_authorization
    end
    out.assign_attributes membership_attributes if out.new_record? && params[:membership]
    out
  end
  filter_access_to :new, :create, :edit, :update, :destroy, :show, :confirm,
    :decline, attribute_check: true, load_method: :membership
  filter_access_to :renew do
    permitted_to! :update, user
  end

  # GET /memberships/:membership_id/decline
  # PUT /memberships/:membership_id/decline
  def decline
    respond_to do |format|
      if request.request_method_symbol == :put
        if membership.decline_renewal( decline_membership_attributes, user: current_user )
          format.html { redirect_to membership, flash: { success: 'Membership renewal declined.' } }
        else
          format.html
        end
      else
        format.html
      end
    end
  end

  # GET /authorities/:authority_id/memberships/renewable
  def renewable
    index
  end

  # GET /users/:user_id/memberships/renew
  # PUT /users/:user_id/memberships/renew
  def renew
    respond_to do |format|
      if request.request_method_symbol == :get
        format.html
      else
        format.html do
          if user.update_attributes( renew_user_memberships_attributes )
            flash[:success] = 'Renewal preferences updated.'
          else
            flash[:error] = 'Renewal preferences not updated.'
          end
          render action: 'renew'
        end
      end
    end
  end

  # GET /committees/:committee_id/memberships/renewed
  # GET /committees/:committee_id/memberships/renewed.xml
  # GET /users/:user_id/memberships/renewed
  # GET /users/:user_id/memberships/renewed.xml
  def renewed
    index
  end

  # GET /committees/:committee_id/memberships/unrenewed
  # GET /committees/:committee_id/memberships/unrenewed.xml
  # GET /users/:user_id/memberships/unrenewed
  # GET /users/:user_id/memberships/unrenewed.xml
  def unrenewed
    index
  end

  # GET /membership_requests/:membership_request_id/memberships/current
  # GET /membership_requests/:membership_request_id/memberships/current.xml
  # GET /positions/:position_id/memberships/current
  # GET /positions/:position_id/memberships/current.xml
  # GET /committees/:committee_id/memberships/current
  # GET /committees/:committee_id/memberships/current.xml
  # GET /users/:user_id/memberships/current
  # GET /users/:user_id/memberships/current.xml
  # GET /authorities/:authority_id/memberships/current
  # GET /authorities/:authority_id/memberships/current.xml
  def current
    index
  end

  # GET /membership_requests/:membership_request_id/memberships/future
  # GET /membership_requests/:membership_request_id/memberships/future.xml
  # GET /positions/:position_id/memberships/future
  # GET /positions/:position_id/memberships/future.xml
  # GET /committees/:committee_id/memberships/future
  # GET /committees/:committee_id/memberships/future.xml
  # GET /users/:user_id/memberships/future
  # GET /users/:user_id/memberships/future.xml
  # GET /authorities/:authority_id/memberships/future
  # GET /authorities/:authority_id/memberships/future.xml
  def future
    index
  end

  # GET /membership_requests/:membership_request_id/memberships/past
  # GET /membership_requests/:membership_request_id/memberships/past.xml
  # GET /positions/:position_id/memberships/past
  # GET /positions/:position_id/memberships/past.xml
  # GET /committees/:committee_id/memberships/past
  # GET /committees/:committee_id/memberships/past.xml
  # GET /users/:user_id/memberships/past
  # GET /users/:user_id/memberships/past.xml
  # GET /authorities/:authority_id/memberships/past
  # GET /authorities/:authority_id/memberships/past.xml
  def past
    index
  end

  # GET /membership_requests/:membership_request_id/memberships/assignable
  def assignable
    index
  end

  # GET /review/membership_requests/active
  def active
    index
  end

  # GET /membership_requests/:membership_request_id/memberships
  # GET /membership_requests/:membership_request_id/memberships.xml
  # GET /positions/:position_id/memberships
  # GET /positions/:position_id/memberships.xml
  # GET /committees/:committee_id/memberships
  # GET /committees/:committee_id/memberships.xml
  # GET /users/:user_id/memberships
  # GET /users/:user_id/memberships.xml
  # GET /authorities/:authority_id/memberships
  # GET /authorities/:authority_id/memberships.xml
  def index
    respond_to do |format|
      format.html { render :action => 'index' }
      format.csv { csv_index }
      format.xml  { render :xml => memberships }
    end
  end

  # POST /positions/:position_id/memberships
  # POST /positions/:position_id/memberships.xml
  def create
    membership.modifier = current_user
    respond_to do |format|
      if membership.save
        format.html { redirect_to( membership, flash: { success: 'Membership created.' } ) }
      else
        populate_designees
        format.html { render action: "new" }
      end
    end
  end

  # PUT /memberships/1
  # PUT /memberships/1.xml
  def update
    membership.modifier = current_user
    respond_to do |format|
      membership.assign_attributes membership_attributes
      if membership.save
        format.html { redirect_to( membership, flash: { success: 'Membership updated.' } ) }
      else
        populate_designees
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /memberships/1
  # DELETE /memberships/1.xml
  def destroy
    membership.destroy

    respond_to do |format|
      format.html { redirect_to position_memberships_url(membership.position),
        flash: { success: "Membership was successfully destroyed." } }
    end
  end

  private

  def csv_index
    csv_string = ""
    CSV.generate csv_string do |csv|
      csv << [ 'first', 'last','netid','email','mobile','position','committee',
        'title','vote','period','starts at','ends at','renew until?' ]
      q.result.all.each do |membership|
        next unless permitted_to?( :show, membership )
        membership.enrollments.each do |enrollment|
          next if committee && (enrollment.committee_id != committee.id)
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
    send_data csv_string, disposition: "attachment; filename=memberships.csv",
      type: :csv
  end

  def populate_designees
    membership.designees.populate
  end
end

