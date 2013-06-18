class SchedulesController < ApplicationController
  expose :q_scope do
    Schedule.scoped
  end
  expose :q do
    q_scope.search( params[:term] ? { name_cont: params[:term] } : params[:q] )
  end
  expose :schedules do
    q.result.ordered.page(params[:page])
  end
  expose :schedule_attributes do
    params.require(:schedule).permit( :name,
      { periods_attributes: [ :id, :_destroy, :starts_at, :ends_at ] } )
  end
  expose :schedule, attributes: :schedule_attributes
  filter_access_to :new, :create, :edit, :update, :destroy, :show,
    load_method: :schedule

  # POST /schedules
  # POST /schedules.xml
  def create
    respond_to do |format|
      if schedule.save
        format.html { redirect_to schedule, flash: { success: 'Schedule created.' } }
        format.xml  { render xml: schedule, status: :created, location: schedule }
      else
        format.html { render action: "new" }
        format.xml  { render xml: schedule.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /schedules/1
  # PUT /schedules/1.xml
  def update
    respond_to do |format|
      if schedule.save
        format.html { redirect_to schedule, flash: { success: 'Schedule updated.' } }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: schedule.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /schedules/1
  # DELETE /schedules/1.xml
  def destroy
    schedule.destroy

    respond_to do |format|
      format.html { redirect_to schedules_url, flash: { success: "Schedule destroyed." } }
      format.xml  { head :ok }
    end
  end
end

