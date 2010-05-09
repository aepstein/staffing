class UserRenewalNoticesController < ApplicationController
  before_filter :require_user
  filter_resource_access

  # GET /user_renewal_notices
  # GET /user_renewal_notices.xml
  def index
    @user_renewal_notices = UserRenewalNotice.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_renewal_notices }
    end
  end

  # GET /user_renewal_notices/1
  # GET /user_renewal_notices/1.xml
  def show
    @user_renewal_notice = UserRenewalNotice.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user_renewal_notice }
    end
  end

  # GET /user_renewal_notices/new
  # GET /user_renewal_notices/new.xml
  def new
    @user_renewal_notice = UserRenewalNotice.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user_renewal_notice }
    end
  end

  # GET /user_renewal_notices/1/edit
  def edit
    @user_renewal_notice = UserRenewalNotice.find(params[:id])
  end

  # POST /user_renewal_notices
  # POST /user_renewal_notices.xml
  def create
    @user_renewal_notice = UserRenewalNotice.new(params[:user_renewal_notice])

    respond_to do |format|
      if @user_renewal_notice.save
        flash[:notice] = 'User renewal notice was successfully created.'
        format.html { redirect_to(@user_renewal_notice) }
        format.xml  { render :xml => @user_renewal_notice, :status => :created, :location => @user_renewal_notice }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user_renewal_notice.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /user_renewal_notices/1
  # PUT /user_renewal_notices/1.xml
  def update
    @user_renewal_notice = UserRenewalNotice.find(params[:id])

    respond_to do |format|
      if @user_renewal_notice.update_attributes(params[:user_renewal_notice])
        flash[:notice] = 'User renewal notice was successfully updated.'
        format.html { redirect_to(@user_renewal_notice) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user_renewal_notice.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /user_renewal_notices/1
  # DELETE /user_renewal_notices/1.xml
  def destroy
    @user_renewal_notice = UserRenewalNotice.find(params[:id])
    @user_renewal_notice.destroy

    respond_to do |format|
      format.html { redirect_to(user_renewal_notices_url) }
      format.xml  { head :ok }
    end
  end
end

