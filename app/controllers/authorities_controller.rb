class AuthoritiesController < ApplicationController
  expose :authority
  expose :authorities
  filter_resource_access load_method: :authority

  # GET /authorities
  # GET /authorities.xml
  def index
    respond_with users
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
        format.html { render :action => "edit" }
        format.xml  { render xml: authority.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /authorities/1
  # DELETE /authorities/1.xml
  def destroy
    authority.destroy

    respond_to do |format|
      format.html { redirect_to authorities_url, flash: { success: 'Authority was successfully destroyed.' } }
      format.xml  { head :ok }
    end
  end
end

