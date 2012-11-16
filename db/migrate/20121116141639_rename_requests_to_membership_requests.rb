class RenameRequestsToMembershipRequests < ActiveRecord::Migration
  def up
    # Answers
    remove_index :answers, [ :question_id, :request_id ]
    rename_column :answers, :request_id, :membership_request_id
    add_index :answers, [ :question_id, :membership_request_id ], unique: true
    # Memberships
    rename_column :memberships, :request_id, :membership_request_id
    add_index :memberships, :membership_request_id
    # Requests
    remove_index :requests, :close_notice_at
    remove_index :requests, :closed_at
    remove_index :requests, :reject_notice_at
    remove_index :requests, :status
    remove_index :requests, [ :user_id, :committee_id ]
    rename_table :requests, :membership_requests
    add_index :membership_requests, :close_notice_at
    add_index :membership_requests, :closed_at
    add_index :membership_requests, :reject_notice_at
    add_index :membership_requests, :status
    add_index :membership_requests, [ :user_id, :committee_id ], unique: true, name: "unique_user_and_committee"
  end

  def down
    # Answers
    remove_index :answers, [ :question_id, :membership_request_id ]
    rename_column :answers, :membership_request_id, :request_id
    add_index :answers, [ :question_id, :request_id ], unique: true
    # Memberships
    remove_index :memberships, :membership_request_id
    rename_column :memberships, :membership_request_id, :request_id
    # Requests
    remove_index :membership_requests, :close_notice_at
    remove_index :membership_requests, :closed_at
    remove_index :membership_requests, :reject_notice_at
    remove_index :membership_requests, :status
    remove_index :membership_requests, name: "unique_user_and_committee"
    rename_table :membership_requests, :requests
    add_index :requests, [ :user_id, :committee_id ], unique: true
    add_index :requests, :status
    add_index :requests, :reject_notice_at
    add_index :requests, :closed_at
    add_index :requests, :close_notice_at
  end
end

