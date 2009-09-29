class AuthoritiesController < ApplicationController
  # GET /authorities
  # GET /authorities.xml
  def index
    @authorities = Authority.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @authorities }
    end
  end

  # GET /authorities/1
  # GET /authorities/1.xml
  def show
    @authority = Authority.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @authority }
    end
  end

  # GET /authorities/new
  # GET /authorities/new.xml
  def new
    @authority = Authority.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @authority }
    end
  end

  # GET /authorities/1/edit
  def edit
    @authority = Authority.find(params[:id])
  end

  # POST /authorities
  # POST /authorities.xml
  def create
    @authority = Authority.new(params[:authority])

    respond_to do |format|
      if @authority.save
        flash[:notice] = 'Authority was successfully created.'
        format.html { redirect_to(@authority) }
        format.xml  { render :xml => @authority, :status => :created, :location => @authority }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @authority.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /authorities/1
  # PUT /authorities/1.xml
  def update
    @authority = Authority.find(params[:id])

    respond_to do |format|
      if @authority.update_attributes(params[:authority])
        flash[:notice] = 'Authority was successfully updated.'
        format.html { redirect_to(@authority) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @authority.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /authorities/1
  # DELETE /authorities/1.xml
  def destroy
    @authority = Authority.find(params[:id])
    @authority.destroy

    respond_to do |format|
      format.html { redirect_to(authorities_url) }
      format.xml  { head :ok }
    end
  end
end
