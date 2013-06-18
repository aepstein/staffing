class AuthoritiesController < ApplicationController
  expose :authority, attributes: :authority_params
  expose :authorities
  expose :authority_params do
    params.require(:authority).permit( :name, :join_message, :leave_message,
    :committee_id, :committee_name, :contact_name, :contact_email,
    :reject_message, :appoint_message )
  end
  filter_access_to :new, :create, :edit, :update, :index, :destroy
  respond_to :html, :xml

  # GET /authorities
  # GET /authorities.xml
  def index
    respond_with authorities
  end

  # POST /authorities
  # POST /authorities.xml
  def create
    respond_to do |format|
      if authority.save
        format.html { redirect_to authority, flash: { success: 'Authority created.' } }
        format.xml  { render xml: authority, status: :created, location: authority }
      else
        format.html { render action: "new" }
        format.xml  { render xml: authority.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /authorities/1
  # PUT /authorities/1.xml
  def update
    respond_to do |format|
      if authority.save
        format.html { redirect_to authority, flash: { success: 'Authority updated.' } }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: authority.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /authorities/1
  # DELETE /authorities/1.xml
  def destroy
    authority.destroy

    respond_to do |format|
      format.html { redirect_to authorities_url, flash: { success: 'Authority destroyed.' } }
      format.xml  { head :ok }
    end
  end
end

