class CreateUserRenewalNotices < ActiveRecord::Migration
  def self.up
    create_table :user_renewal_notices do |t|
      t.date :starts_at
      t.date :ends_at
      t.date :deadline
      t.references :authority
      t.text :message

      t.timestamps
    end
  end

  def self.down
    drop_table :user_renewal_notices
  end
end
