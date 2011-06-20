class AddAttachmentVectorToLogo < ActiveRecord::Migration
  def self.up
    add_column :logos, :vector_file_name, :string
    add_column :logos, :vector_content_type, :string
    add_column :logos, :vector_file_size, :integer
    add_column :logos, :vector_updated_at, :datetime
  end

  def self.down
    remove_column :logos, :vector_file_name
    remove_column :logos, :vector_content_type
    remove_column :logos, :vector_file_size
    remove_column :logos, :vector_updated_at
  end
end
