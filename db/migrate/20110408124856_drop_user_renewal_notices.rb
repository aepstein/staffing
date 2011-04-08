class DropUserRenewalNotices < ActiveRecord::Migration
  def self.up
    drop_table :user_renewal_notices
  end

  def self.down
    create_table :user_renewal_notices do |t|
      t.date     :starts_at
      t.date     :ends_at
      t.date     :deadline
      t.integer  :authority_id
      t.text     :message
      t.boolean  :sendings_populated
      t.timestamps
    end
  end
end

