class LogosToBrands < ActiveRecord::Migration
  def self.up
    rename_table :logos, :brands
    rename_column :brands, :vector, :logo
    rename_column :committees, :logo_id, :brand_id
  end

  def self.down
    rename_column :committees, :brand_id, :logo_id
    rename_column :brands, :logo, :vector
    rename_table :brands, :logos
  end
end

