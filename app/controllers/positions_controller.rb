class PositionsController < ApplicationController
  expose( :committee ) { Committee.find params[:committee_id] if params[:committee_id] }
  expose( :user ) { User.find params[:user_id] if params[:user_id] }
  expose( :context ) { committee || user }
  expose :q_scope do
    scope = context.positions if context
    scope ||= Position.scoped
    case params[:action]
    when 'current', 'past', 'future', 'requestable'
      scope.send params[:action]
    else
      scope.scoped
    end
  end
  expose( :q ) { q_scope.search( params[:term] ? { name_cont: params[:term] } : params[:q] ) }
  expose( :positions ) { q.result.ordered.page(params[:page]) }
  expose :position
  filter_access_to :new, :create, :edit, :update, :destroy, :show
  filter_access_to :requestable, :index do
    permitted_to!( :show, user ) if user
    permitted_to! :index
  end

  # GET /users/:user_id/positions/requestable
  # GET /users/:user_id/positions/requestable.xml
  def requestable
    index
  end

  # GET /positions
  # GET /positions.xml
  # GET /committees/:committee_id/positions
  # GET /committees/:committee_id/positions.xml
  def index
    respond_to do |format|
      format.html { render action: 'index' } # index.html.erb
      format.json # index.json.erb
      format.xml  { render xml: positions }
    end
  end

  # POST /positions
  # POST /positions.xml
  def create
    respond_to do |format|
      if position.save
        format.html { redirect_to( position, flash: { success: 'Position created.' } ) }
        format.xml  { render xml: position, status: :created, location: position }
      else
        format.html { render action: "new" }
        format.xml  { render xml: position.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /positions/1
  # PUT /positions/1.xml
  def update
    respond_to do |format|
      if position.save
        format.html { redirect_to( position, flash: { success: 'Position updated.' } ) }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: position.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /positions/1
  # DELETE /positions/1.xml
  def destroy
    position.destroy

    respond_to do |format|
      format.html { redirect_to( positions_url, flash: { success: "Position destroyed." } ) }
      format.xml  { head :ok }
    end
  end
end

