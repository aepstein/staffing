class SendingsController < ApplicationController
  # GET /sendings
  # GET /sendings.xml
  def index
    @sendings = Sending.all

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

  # GET /sendings/new
  # GET /sendings/new.xml
  def new
    @sending = Sending.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @sending }
    end
  end

  # GET /sendings/1/edit
  def edit
    @sending = Sending.find(params[:id])
  end

  # POST /sendings
  # POST /sendings.xml
  def create
    @sending = Sending.new(params[:sending])

    respond_to do |format|
      if @sending.save
        flash[:notice] = 'Sending was successfully created.'
        format.html { redirect_to(@sending) }
        format.xml  { render :xml => @sending, :status => :created, :location => @sending }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @sending.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /sendings/1
  # PUT /sendings/1.xml
  def update
    @sending = Sending.find(params[:id])

    respond_to do |format|
      if @sending.update_attributes(params[:sending])
        flash[:notice] = 'Sending was successfully updated.'
        format.html { redirect_to(@sending) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @sending.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /sendings/1
  # DELETE /sendings/1.xml
  def destroy
    @sending = Sending.find(params[:id])
    @sending.destroy

    respond_to do |format|
      format.html { redirect_to(sendings_url) }
      format.xml  { head :ok }
    end
  end
end
