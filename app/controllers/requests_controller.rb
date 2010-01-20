class RequestsController < ApplicationController
  filter_resource_access

  # GET /position/:position_id/requests
  # GET /position/:position_id/requests.xml
  def index
    @position = Position.find(params[:position_id])
    @requests = @position.requests

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @requests }
    end
  end

  # GET /requests/1
  # GET /requests/1.xml
  def show
    @request = Request.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @request }
    end
  end

  # GET /position/:position_id/requests/new
  # GET /position/:position_id/requests/new.xml
  def new
    @request = Position.find(params[:position_id]).requests.build
    raise AuthorizationError unless current_user
    @request.user = current_user
    @request.answers.populate

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @request }
    end
  end

  # GET /requests/1/edit
  def edit
    @request = Request.find(params[:id])
  end

  # POST /position/:position_id/requests
  # POST /position/:position_id/requests.xml
  def create
    @request = Position.find(params[:position_id]).requests.build(params[:request])
    raise AuthorizationError unless current_user
    @request.user = current_user

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
    @request = Request.find(params[:id])

    respond_to do |format|
      if @request.update_attributes(params[:request])
        flash[:notice] = 'Request was successfully updated.'
        format.html { redirect_to(@request) }
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
    @request = Request.find(params[:id])
    @request.destroy

    respond_to do |format|
      format.html { redirect_to position_requests_url @request.position }
      format.xml  { head :ok }
    end
  end
end

