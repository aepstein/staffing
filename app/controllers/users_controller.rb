class UsersController < ApplicationController
  expose :role do
    if permitted_to?( :manage, user )
      return :admin
    else
      permitted_to?(:staff, user) ? :staff : :default
    end
  end
  expose( :membership ) { Membership.find( params[:membership_id] ) if params[:membership_id] }
  expose( :motion ) { Motion.find( params[:motion_id] ) if params[:motion_id] }
  expose( :committee ) { Committee.find( params[:committee_id] ) if params[:committee_id] }
  expose( :context ) { membership || motion || committee }
  expose :q_scope do
    scope = context.users if context
    scope ||= User.scoped
    case params[:action]
    when 'allowed'
      scope.allowed
    when 'staff', 'admin'
      scope.where( params[:action] => true )
    else
      scope.scoped
    end
  end
  expose( :q ) { q_scope.search( params[:term] ? { name_cont: params[:term] } : params[:q] ) }
  expose( :users ) { q.result.with_permissions_to(:show).ordered.page(params[:page]) }
  expose :user do
    out = if params[:id]
      User.find(params[:id])
    else
      User.new
    end
    out.assign_attributes( params[:user], as: role ) if out.new_record?
    out
  end
  filter_access_to :new, :create, :edit, :update, :destroy, :show, :tent,
    attribute_check: true, load_method: :user
  filter_access_to :admin, :import_empl_id, :do_import_empl_id, :staff do
    permitted_to! :staff, :users
  end

  # GET /users/import_empl_id
  def import_empl_id; end

  # PUT /users/do_import_empl_id
  def do_import_empl_id
    respond_to do |format|
      import_results = 0
      # Add from form field
      unless params[:users].blank?
        import_results += User.import_empl_id_from_csv_string( params[:users] )
      end
      # Add from file
      unless params[:users_file].is_a?( String ) || params[:users_file].blank?
        import_results += User.import_empl_id_from_csv_file( params[:users_file] )
      end
      format.html { redirect_to import_empl_id_users_url, flash: { success: "Processed empl_ids." } }
      format.xml { head :ok }
    end
  end

  # GET /motions/:motion_id/users/allowed
  # GET /motions/:motion_id/users/allowed
  def allowed; index; end

  def staff; index; end

  def admin; index; end

  # GET /motions/:motion_id/users
  # GET /motions/:motion_id/users
  # GET /meetings/:meetings_id/users
  # GET /meetings/:meetings_id/users
  # GET /users
  # GET /users.xml
  def index
    respond_to do |format|
      format.html { render action: 'index' } # index.html.erb
      format.json { render action: 'index' } # index.json.erb
      format.xml  { render xml: users }
    end
  end

  # GET /users/:id/tent.pdf
  include UserTentReports
  def tent
    context = user
    tents = [ [ user.name, params[:title],
      ( user.portrait? ? user.portrait.small.path : nil ) ] ]
    render_user_tent_reports
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.jpg {
        case params[:version]
        when 'small'
          send_file user.portrait.small.path, type: :jpg, disposition: 'inline',
            filename: "#{user.name :file}-small.jpg"
        when 'thumb'
          send_file user.portrait.thumb.path, type: :jpg, disposition: 'inline',
            filename: "#{user.name :file}-thumb.jpg"
        else
          send_file user.portrait.path, type: :jpg, disposition: 'inline',
            filename: "#{user.name :file}.jpg"
        end
      }
      format.xml  { render xml: user }
    end
  end

  # GET /users/1/resume.pdf
  def resume
    respond_to do |format|
      format.pdf do
        if user.resume.blank?
          head(:not_found)
        else
          send_file user.resume.path, filename: "#{user.name :file}-resume.pdf",
            type: :pdf, disposition: 'inline'
        end
      end
    end
  end

  # POST /users
  # POST /users.xml
  def create
    respond_to do |format|
      if user.save
        format.html { redirect_to user, flash: { success: 'User created.' } }
        format.xml  { render xml: user, status: :created, location: user }
      else
        format.html { render action: "new" }
        format.xml  { render xml: user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    respond_to do |format|
      if user.update_attributes(params[:user], as: role)
        format.html { redirect_to user, flash: { success: 'User updated.' } }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    user.destroy

    respond_to do |format|
      format.html { redirect_to users_url, flash: { success: "User destroyed." } }
      format.xml  { head :ok }
    end
  end
end

