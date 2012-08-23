class AddContactNameContactEmailToCommittees < ActiveRecord::Migration
  def change
    add_column :committees, :contact_name, :string
    add_column :committees, :contact_email, :string
  end
end
