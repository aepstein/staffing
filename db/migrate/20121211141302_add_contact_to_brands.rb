class AddContactToBrands < ActiveRecord::Migration
  def change
    add_column :brands, :phone, :string
    add_column :brands, :fax, :string
    add_column :brands, :email, :string
    add_column :brands, :web, :string
    add_column :brands, :address_1, :string
    add_column :brands, :address_2, :string
    add_column :brands, :city, :string
    add_column :brands, :state, :string
    add_column :brands, :zip, :string
  end
end
