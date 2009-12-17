class MembershipsController < ApplicationController
  before_filter :initialize_contexts
  # GET /positions/:position_id/memberships
  # GET /positions/:position_id/memberships.xml
  def index
    @memberships ||= @request.memberships if @request
    @memberships ||= @position.memberships if @position
    @memberships ||= Membership.all

    respond_to do |format|
      format.html # index.html.erb
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
    @membership ||= Membership.new(:request => @request) if @request
    @membership ||= @position.memberships.build if @position

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @membership }
    end
  end

  # GET /memberships/1/edit
  def edit
    @membership = Membership.find(params[:id])
  end

  # POST /positions/:position_id/memberships
  # POST /positions/:position_id/memberships.xml
  def create
    @membership ||= Membership.new( params[:membership].merge( :request => @request ) ) if @request
    @membership ||= @position.memberships.build( params[:membership] ) if @position

    respond_to do |format|
      if @membership.save
        flash[:notice] = 'Membership was successfully created.'
        format.html { redirect_to(@membership) }
        format.xml  { render :xml => @membership, :status => :created, :location => @membership }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @membership.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /memberships/1
  # PUT /memberships/1.xml
  def update
    @membership = Membership.find(params[:id])

    respond_to do |format|
      if @membership.update_attributes(params[:membership])
        flash[:notice] = 'Membership was successfully updated.'
        format.html { redirect_to(@membership) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @membership.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /memberships/1
  # DELETE /memberships/1.xml
  def destroy
    @membership = Membership.find(params[:id])
    @membership.destroy

    respond_to do |format|
      format.html { redirect_to position_memberships_url @membership.position }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_contexts
    if params[:request_id]
      @request = Request.find(params[:request_id])
      @position = @request.position
    end
    @position ||= Position.find(params[:position_id]) if params[:position_id]
  end
end

