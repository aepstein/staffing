class PositionsController < ApplicationController
  before_filter :require_user, :initialize_context
  before_filter :new_position_from_params, :only => [ :new, :create ]
  before_filter :setup_breadcrumbs
  filter_access_to :new, :create, :edit, :update, :destroy, :show, :index
  filter_access_to :requestable do
    permitted_to!( :show, @user )
  end

  # GET /users/:user_id/positions/requestable
  # GET /users/:user_id/positions/requestable.xml
  def requestable
    @search ||= @user.positions.requestable.search( params[:search] ) if @user
    index
  end

  # GET /positions
  # GET /positions.xml
  # GET /committees/:committee_id/positions
  # GET /committees/:committee_id/positions.xml
  def index
    search = params[:term] ? { :name_contains => params[:term] } : params[:search]
    @search ||= @committee.positions.search( search ) if @committee
    @search ||= Position.search( search )
    @positions = @search.page( params[:page] )

    respond_to do |format|
      format.html { render :action => 'index' } # index.html.erb
      format.json # index.json.erb
      format.xml  { render :xml => @positions }
    end
  end

  # GET /positions/1
  # GET /positions/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @position }
    end
  end

  # GET /positions/new
  # GET /positions/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @position }
    end
  end

  # GET /positions/1/edit
  def edit
  end

  # POST /positions
  # POST /positions.xml
  def create
    respond_to do |format|
      if @position.save
        flash[:notice] = 'Position was successfully created.'
        format.html { redirect_to(@position) }
        format.xml  { render :xml => @position, :status => :created, :location => @position }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @position.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /positions/1
  # PUT /positions/1.xml
  def update
    respond_to do |format|
      if @position.update_attributes(params[:position])
        flash[:notice] = 'Position was successfully updated.'
        format.html { redirect_to(@position) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @position.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /positions/1
  # DELETE /positions/1.xml
  def destroy
    @position.destroy

    respond_to do |format|
      format.html { redirect_to(positions_url) }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @position = Position.find( params[:id] ) if params[:id]
    @committee = Committee.find( params[:committee_id] ) if params[:committee_id]
    @user = User.find( params[:user_id] ) if params[:user_id]
    @context = @committee || @user
  end

  def new_position_from_params
    @position = Position.new( params[:position] )
  end

  def setup_breadcrumbs
    add_breadcrumb @context, polymorphic_path( @context ) if @context
    add_breadcrumb "Positions", polymorphic_path( [ @context, :positions ] )
    if @position && @position.persisted?
      add_breadcrumb @position, position_path( @position )
    end
  end
end

