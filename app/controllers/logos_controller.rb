class LogosController < ApplicationController
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index ]
  before_filter :new_logo_from_params, :only => [ :new, :create ]
  filter_resource_access
  before_filter :setup_breadcrumbs

  # GET /logos
  # GET /logos.xml
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @logos }
    end
  end

  # GET /logos/1
  # GET /logos/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @logo }
    end
  end

  # GET /logos/new
  # GET /logos/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @logo }
    end
  end

  # GET /logos/1/edit
  def edit
  end

  # POST /logos
  # POST /logos.xml
  def create
    respond_to do |format|
      if @logo.save
        flash[:notice] = 'Logo was successfully created.'
        format.html { redirect_to(@logo) }
        format.xml  { render :xml => @logo, :status => :created, :location => @logo }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @logo.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /logos/1
  # PUT /logos/1.xml
  def update
    respond_to do |format|
      if @logo.update_attributes(params[:logo])
        flash[:notice] = 'Logo was successfully updated.'
        format.html { redirect_to(@logo) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @logo.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /logos/1
  # DELETE /logos/1.xml
  def destroy
    @logo.destroy

    respond_to do |format|
      format.html { redirect_to(logos_url) }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @logo = Logo.find params[:id] if params[:id]
  end

  def initialize_index
    @logos = Logo.scoped
  end

  def new_logo_from_params
    Logo.new( params[:logo] )
  end

  def setup_breadcrumbs
    add_breadcrumb 'Logos', logos_path
    if @logo && @logo.persisted?
      add_breadcrumb @logo, logo_path( @logo )
    end
  end
end

