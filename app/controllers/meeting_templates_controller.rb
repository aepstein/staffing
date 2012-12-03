class MeetingTemplatesController < ApplicationController
  before_filter :initialize_context
  before_filter :new_meeting_template_from_params, only: [ :new, :create ]
  filter_resource_access
  before_filter :setup_breadcrumbs

  # GET /meeting_templates
  # GET /meeting_templates.xml
  def index
    search = params[:term] ? { name_cont: params[:term] } : params[:q]
    @q ||= MeetingTemplate.search( search )
    @meeting_templates = @q.result.ordered.page( params[:page] )

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @meeting_templates }
    end
  end

  # GET /meeting_templates/1
  # GET /meeting_templates/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @meeting_template }
    end
  end

  # GET /meeting_templates/new
  # GET /meeting_templates/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @meeting_template }
    end
  end

  # GET /meeting_templates/1/edit
  def edit
  end

  # POST /meeting_templates
  # POST /meeting_templates.xml
  def create
    respond_to do |format|
      if @meeting_template.save
        flash[:notice] = 'Meeting template was successfully created.'
        format.html { redirect_to(@meeting_template) }
        format.xml  { render xml: @meeting_template, status: :created, location: @meeting_template }
      else
        format.html { render action: "new" }
        format.xml  { render xml: @meeting_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /meeting_templates/1
  # PUT /meeting_templates/1.xml
  def update
    respond_to do |format|
      if @meeting_template.update_attributes(params[:meeting_template])
        flash[:notice] = 'Meeting template was successfully updated.'
        format.html { redirect_to(@meeting_template) }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @meeting_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /meeting_templates/1
  # DELETE /meeting_templates/1.xml
  def destroy
    @meeting_template.destroy

    respond_to do |format|
      format.html { redirect_to(meeting_templates_url, notice: "Meeting template was successfully destroyed.") }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @meeting_template = MeetingTemplate.find params[:id] if params[:id]
  end

  def new_meeting_template_from_params
    @meeting_template = MeetingTemplate.new( params[:meeting_template] )
  end

  def setup_breadcrumbs
    add_breadcrumb 'Meeting templates', meeting_templates_path
    if @meeting_template && @meeting_template.persisted?
      add_breadcrumb @meeting_template, meeting_template_path( @meeting_template )
    end
  end
end

