class PeriodsController < ApplicationController
  before_filter :initialize_context
  before_filter :new_period_from_params, :only => [ :new, :create ]
  filter_access_to :new, :create, :edit, :update, :destroy, :show,
    :attribute_check => true
  before_filter :setup_breadcrumbs

  # GET /schedule/:schedule_id/periods
  # GET /schedule/:schedule_id/periods.xml
  def index
    @periods = @schedule.periods

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @periods }
    end
  end

  # GET /periods/1
  # GET /periods/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @period }
    end
  end

  # GET /schedule/:schedule_id/periods/new
  # GET /schedule/:schedule_id/periods/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @period }
    end
  end

  # GET /periods/1/edit
  def edit
  end

  # POST /schedule/:schedule_id/periods
  # POST /schedule/:schedule_id/periods.xml
  def create
    respond_to do |format|
      if @period.save
        flash[:notice] = 'Period was successfully created.'
        format.html { redirect_to(@period) }
        format.xml  { render :xml => @period, :status => :created, :location => @period }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @period.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /periods/1
  # PUT /periods/1.xml
  def update
    respond_to do |format|
      if @period.update_attributes(params[:period])
        flash[:notice] = 'Period was successfully updated.'
        format.html { redirect_to(@period) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @period.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /periods/1
  # DELETE /periods/1.xml
  def destroy
    @period.destroy

    respond_to do |format|
      format.html { redirect_to schedule_periods_url @period.schedule  }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @period = Period.find(params[:id]) if params[:id]
    @schedule = Schedule.find(params[:schedule_id]) if params[:schedule_id]
    @schedule ||= @period.schedule if @period
  end

  def new_period_from_params
    @period = @schedule.periods.build( params[:period] )
  end

  def setup_breadcrumbs
    add_breadcrumb 'Schedules', schedules_path
    if @schedule
      add_breadcrumb @schedule.name, schedule_path( @schedule )
      add_breadcrumb 'Periods', schedule_periods_path( @schedule )
    end
    if @period && @period.persisted?
      add_breadcrumb @period, period_path( @period )
    end
  end
end

