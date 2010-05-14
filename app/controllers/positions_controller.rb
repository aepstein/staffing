class PositionsController < ApplicationController
  before_filter :require_user, :initialize_context
  filter_resource_access

  # GET /users/:user_id/positions/requestable
  # GET /users/:user_id/positions/requestable.xml
  def requestable
    @search ||= @user.requestable_positions.search( params[:search] ) if @user
    index
  end

  # GET /positions
  # GET /positions.xml
  # GET /committees/:committee_id/positions
  # GET /committees/:committee_id/positions.xml
  def index
    @search ||= @committee.positions.search( params[:search] ) if @committee
    @search ||= Position.search( params[:search] )
    @positions = @search.paginate( :page => params[:page] )

    respond_to do |format|
      format.html { render :action => 'index' } # index.html.erb
      format.js # index.js.erb
      format.xml  { render :xml => @positions }
    end
  end

  # GET /positions/1
  # GET /positions/1.xml
  def show
    @position = Position.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @position }
    end
  end

  # GET /positions/new
  # GET /positions/new.xml
  def new
    @position = Position.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @position }
    end
  end

  # GET /positions/1/edit
  def edit
    @position = Position.find(params[:id])
  end

  # POST /positions
  # POST /positions.xml
  def create
    @position = Position.new(params[:position])

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
    @position = Position.find(params[:id])

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
    @position = Position.find(params[:id])
    @position.destroy

    respond_to do |format|
      format.html { redirect_to(positions_url) }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @committee = Committee.find(params[:committee_id]) if params[:committee_id]
    @user = User.find(params[:user_id]) if params[:user_id]
  end
end

