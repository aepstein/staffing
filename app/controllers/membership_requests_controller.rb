class MembershipRequestsController < ApplicationController
  before_filter :require_user
  before_filter :populate_answers, only: [ :new, :edit ]
  expose :committee { Committee.find params[:committee_id] if params[:committee_id] }
  expose :authority { Authority.find params[:authority_id] if params[:authority_id] }
  expose :user { User.find params[:user_id] if params[:user_id] }
  expose :context { authority || committee || user }
  expose :q_scope do
    scope = context.membership_requests.scoped if context
    scope ||= MembershipRequest.scoped
    scope = scope.expired if request.action_name == 'expired'
    scope = scope.unexpired if request.action_name == 'unexpired'
    scope = scope.active if request.action_name == 'active'
    scope = scope.inactive if request.action_name == 'inactive'
    scope = scope.rejected if request.action_name == 'rejected'
  end
  expose :q do
    q_scope.search( params[:q] )
  end
  expose :membership_requests do
    q.result.ordered.with_permissions_to(:show)
  end
  expose :assigner_role do
    case action_name
    when 'reject'
      :rejector
    else
      :default
    end
  end
  expose :membership_request do
    out = if params[:id]
      MembershipRequest.find params[:id]
    else
      committee.membership_requests.where( user_id: current_user.id ).first ||
      committee.membership_requests.build
    end
    out.user ||= current_user
    out.assign_attributes params[:membership_request], as: assigner_role
    out
  end
  filter_access_to :new, :create, :edit, :update, :destroy, :show, :reject,
    :reactivate, attribute_check: true, load_method: :membership_request
  filter_access_to :index, :renewed, :unrenewed, :expired, :unexpired, :active,
    :inactive, :rejected do
    user ? permitted_to!( :show, user ) : permitted_to!( :index )
  end

  # GET /position/:position_id/membership_requests
  # GET /position/:position_id/membership_requests.xml
  # GET /committee/:committee_id/membership_requests
  # GET /committee/:committee_id/membership_requests.xml
  # GET /user/:user_id/membership_requests
  # GET /user/:user_id/membership_requests.xml
  def index
    unless params[:format] == 'csv'
      membership_requests = membership_requests.page( params[:page] )
    end

    respond_to do |format|
      format.csv { index_csv }
      format.html { render action: 'index' } # index.html.erb
    end
  end

  # GET /user/:user_id/membership_requests/active
  # GET /user/:user_id/membership_requests/active.xml
  def active
    index
  end

  # GET /user/:user_id/membership_requests/inactive
  # GET /user/:user_id/membership_requests/inactive.xml
  def inactive
    index
  end

  # GET /user/:user_id/membership_requests/rejected
  # GET /user/:user_id/membership_requests/rejected.xml
  def rejected
    index
  end

  # GET /user/:user_id/membership_requests/expired
  # GET /user/:user_id/membership_requests/expired.xml
  def expired
    index
  end

  # GET /user/:user_id/membership_requests/unexpired
  # GET /user/:user_id/membership_requests/unexpired.xml
  def unexpired
    index
  end

  # POST /positions/:position_id/membership_requests
  # POST /positions/:position_id/membership_requests.xml
  # POST /committees/:committee_id/membership_requests
  # POST /committees/:committee_id/membership_requests.xml
  # POST /memberships/:membership_id/membership_requests
  # POST /memberships/:membership_id/membership_requests.xml
  def create
    respond_to do |format|
      if membership_request.save
        format.html { redirect_to( membership_request, flash: { success: "Membership request created." } ) }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /membership_requests/1
  # PUT /membership_requests/1.xml
  def update
    respond_to do |format|
      if ( membership_request.active? && membership_request.save ) || membership_request.reactivate
        format.html { redirect_to( membership_request, flash: { success: "Membership request updated and active." } ) }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # GET /membership_requests/:id/reject
  # PUT /membership_requests/:id/reject
  def reject
    respond_to do |format|
      if request.request_method_symbol == :put
        membership_request.rejected_by_user = current_user
        if membership_request.reject
          format.html { redirect_to( membership_request, flash: { success: 'Membership request rejected.' } ) }
        else
          format.html { render action: "reject" }
        end
      else
        membership_request.rejected_by_authority ||= ( current_user.authorities.authorized.to_a & membership_request.authorities ).first
      end
    end
  end

  # PUT /membership_requests/1/reactivate
  # PUT /membership_requests/1/reactivate.xml
  def reactivate
    respond_to do |format|
      if membership_request.reactivate
        format.html { redirect_to( membership_request, flash: { success: "Membership request reactivated." } ) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /membership_requests/1
  # DELETE /membership_requests/1.xml
  def destroy
    membership_request.destroy

    respond_to do |format|
      format.html { redirect_to( polymorphic_url( [ membership_request.committee, :membership_requests ] ),
        flash: { success: 'Membership request destroyed.' } ) }
      format.xml  { head :ok }
    end
  end

  private

  def index_csv
    csv_string = CSV.generate do |csv|
      csv << %w( net_id first last status committee until )
      membership_requests.all.each do |membership_request|
        csv << [ membership_request.user.net_id, membership_request.user.first_name,
          membership_request.user.last_name, membership_request.user.status,
          membership_request.committee, membership_request.ends_at ]
      end
    end
    send_data csv_string, disposition: "attachment; filename=membership_requests.csv",
      type: :csv
  end

  def populate_answers
    membership_request.answers.populate
  end

end

