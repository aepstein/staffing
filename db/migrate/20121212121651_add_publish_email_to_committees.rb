class AddPublishEmailToCommittees < ActiveRecord::Migration
  def change
    add_column :committees, :publish_email, :string
  end
end
