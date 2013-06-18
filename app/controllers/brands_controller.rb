class BrandsController < ApplicationController
  expose :brands
  expose :brand, attributes: :brand_attributes
  expose :brand_attributes do
    params.require(:brand).permit( :name, :logo, :phone, :fax, :email, :web,
    :address_1, :address_2, :city, :state, :zip )
  end
  filter_access_to :index, :new, :create, :edit, :update, :destroy, :show,
    load_method: :brand
  filter_access_to :thumb, require: :show, load_method: :brand

  # GET /brands/:id/thumb.png
  def thumb
    respond_to do |format|
      format.png { send_file brand.logo.thumb.store_path, type: :png,
        disposition: 'inline'  }
    end
  end

  # POST /brands
  # POST /brands.xml
  def create
    respond_to do |format|
      if brand.save
        format.html { redirect_to brand, flash: { success: 'Brand created.' } }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /brands/1
  # PUT /brands/1.xml
  def update
    respond_to do |format|
      if brand.save
        format.html { redirect_to brand, flash: { success: 'Brand updated.' } }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /brands/1
  # DELETE /brands/1.xml
  def destroy
    brand.destroy

    respond_to do |format|
      format.html { redirect_to brands_url, flash: { success: 'Brand destroyed.' } }
    end
  end
end

