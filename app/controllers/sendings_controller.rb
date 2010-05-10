class SendingsController < ApplicationController
  before_filter :require_user, :initialize_context
  filter_resource_access

  # GET /users/:user_id/sendings
  # GET /users/:user_id/sendings.xml
  # GET /user_renewal_notices/:user_renewal_notice_id/sendings
  # GET /user_renewal_notices/:user_renewal_notice_id/sendings.xml
  def index
    @sendings ||= @context.sendings if @context

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sendings }
    end
  end

  # GET /sendings/1
  # GET /sendings/1.xml
  def show
    @sending = Sending.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @sending }
    end
  end

  # DELETE /sendings/1
  # DELETE /sendings/1.xml
  def destroy
    @sending = Sending.find(params[:id])
    @sending.destroy

    respond_to do |format|
      format.html { redirect_to polymorphic_url( [ @sending.message, :sendings ] ) }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @context ||= UserRenewalNotice.find params[:user_renewal_notice_id] if params[:user_renewal_notice_id]
    @context ||= User.find params[:user_id] if params[:user_id]
  end
end

