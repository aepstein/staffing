class BrandsController < ApplicationController
  before_filter :initialize_context
  before_filter :initialize_index, only: [ :index ]
  before_filter :new_brand_from_params, only: [ :new, :create ]
  filter_resource_access
  filter_access_to :thumb do
    permitted_to! :show
  end
  before_filter :setup_breadcrumbs


  # GET /brands/:id/thumb.png
  def thumb
    respond_to do |format|
      format.png { send_file @brand.logo.thumb.store_path, type: :png,
        disposition: 'inline'  }
    end
  end

  # GET /brands
  # GET /brands.xml
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @brands }
    end
  end

  # GET /brands/1
  # GET /brands/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @brand }
    end
  end

  # GET /brands/new
  # GET /brands/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @brand }
    end
  end

  # GET /brands/1/edit
  def edit
  end

  # POST /brands
  # POST /brands.xml
  def create
    respond_to do |format|
      if @brand.save
        flash[:notice] = 'Brand was successfully created.'
        format.html { redirect_to(@brand) }
        format.xml  { render xml: @brand, status: :created, location: @brand }
      else
        format.html { render action: "new" }
        format.xml  { render xml: @brand.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /brands/1
  # PUT /brands/1.xml
  def update
    respond_to do |format|
      if @brand.update_attributes(params[:brand])
        flash[:notice] = 'Brand was successfully updated.'
        format.html { redirect_to(@brand) }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @brand.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /brands/1
  # DELETE /brands/1.xml
  def destroy
    @brand.destroy

    respond_to do |format|
      format.html { redirect_to(brands_url, notice: 'Brand was successfully destroyed.') }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @brand = Brand.find params[:id] if params[:id]
  end

  def initialize_index
    @brands = Brand.scoped
  end

  def new_brand_from_params
    Brand.new( params[:brand] )
  end

  def setup_breadcrumbs
    add_breadcrumb 'Brands', brands_path
    if @brand && @brand.persisted?
      add_breadcrumb @brand, brand_path( @brand )
    end
  end
end

