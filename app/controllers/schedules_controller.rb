class SchedulesController < ApplicationController
  before_filter :initialize_context
  before_filter :new_schedule_from_params, :only => [ :new, :create ]
  filter_resource_access
  before_filter :setup_breadcrumbs

  # GET /schedules
  # GET /schedules.xml
  def index
    search = params[:term] ? { :name_cont => params[:term] } : params[:q]
    @q ||= Schedule.search( search )
    @schedules = @q.result.ordered.page( params[:page] )

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @schedules }
    end
  end

  # GET /schedules/1
  # GET /schedules/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @schedule }
    end
  end

  # GET /schedules/new
  # GET /schedules/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @schedule }
    end
  end

  # GET /schedules/1/edit
  def edit
  end

  # POST /schedules
  # POST /schedules.xml
  def create
    respond_to do |format|
      if @schedule.save
        flash[:notice] = 'Schedule was successfully created.'
        format.html { redirect_to(@schedule) }
        format.xml  { render :xml => @schedule, :status => :created, :location => @schedule }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @schedule.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /schedules/1
  # PUT /schedules/1.xml
  def update
    respond_to do |format|
      if @schedule.update_attributes(params[:schedule])
        flash[:notice] = 'Schedule was successfully updated.'
        format.html { redirect_to(@schedule) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @schedule.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /schedules/1
  # DELETE /schedules/1.xml
  def destroy
    @schedule.destroy

    respond_to do |format|
      format.html { redirect_to(schedules_url, notice: "Schedule was successfully destroyed.") }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @schedule = Schedule.find params[:id] if params[:id]
  end

  def new_schedule_from_params
    @schedule = Schedule.new( params[:schedule] )
  end

  def setup_breadcrumbs
    add_breadcrumb 'Schedules', schedules_path
    if @schedule && @schedule.persisted?
      add_breadcrumb @schedule, schedule_path( @schedule )
    end
  end
end

