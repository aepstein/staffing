class MeetingTemplatesController < ApplicationController
  expose( :q_scope ) { MeetingTemplate.all }
  expose( :search ) { params[:term] ? { name_cont: params[:term] } : params[:q] }
  expose( :q ) { q_scope.search( search ) }
  expose( :meeting_templates ) { q.result.ordered.page(params[:page]) }
  expose :meeting_template_attributes do
    if params[:meeting_template]
      params.require(:meeting_template).permit( :name,
        { meeting_section_templates_attributes: MeetingSectionTemplate::PERMITTED_ATTRIBUTES } )
    else
      {}
    end
  end
  expose :meeting_template, attributes: :meeting_template_attributes
  filter_access_to :new, :create, :edit, :update, :destroy, :show, :index,
    attribute_check: true, load_method: :meeting_template

  # GET /meeting_templates
  def index
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # POST /meeting_templates
  # POST /meeting_templates.xml
  def create
    respond_to do |format|
      if meeting_template.save
        format.html { redirect_to( meeting_template, flash: { success: 'Meeting template created.' } ) }
        format.xml  { render xml: meeting_template, status: :created, location: meeting_template }
      else
        format.html { render action: "new" }
        format.xml  { render xml: meeting_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /meeting_templates/1
  # PUT /meeting_templates/1.xml
  def update
    respond_to do |format|
      if meeting_template.save
        format.html { redirect_to( meeting_template, flash: { success: "Meeting template updated." } ) }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: meeting_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /meeting_templates/1
  # DELETE /meeting_templates/1.xml
  def destroy
    meeting_template.destroy

    respond_to do |format|
      format.html { redirect_to(meeting_templates_url, flash: { sucess: "Meeting template destroyed." } ) }
      format.xml  { head :ok }
    end
  end
end

