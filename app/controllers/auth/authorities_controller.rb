module Auth
  class AuthoritiesController < ApplicationController
    expose :authority
    expose :authorities
    filter_access_to :new, :create, :edit, :update, :index, :destroy
    respond_to :html, :xml

    # GET /auth/authorities
    # GET /auth/authorities.xml
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

    # PUT /auth/authorities/1
    # PUT /auth/authorities/1.xml
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

    # DELETE /auth/authorities/1
    # DELETE /auth/authorities/1.xml
    def destroy
      authority.destroy

      respond_to do |format|
        format.html { redirect_to authorities_url, flash: { success: 'Authority destroyed.' } }
        format.xml  { head :ok }
      end
    end
  end
end
