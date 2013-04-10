class AddOnBehalfOfToSponsorships < ActiveRecord::Migration
  def change
    add_column :sponsorships, :on_behalf_of, :string
  end
end
