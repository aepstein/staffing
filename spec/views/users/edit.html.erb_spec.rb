require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/users/edit.html.erb" do
  include UsersHelper

  before(:each) do
    assigns[:user] = @user = stub_model(User,
      :new_record? => false,
      :first_name => "value for first_name",
      :middle_name => "value for middle_name",
      :last_name => "value for last_name",
      :email => "value for email",
      :mobile_phone => "value for mobile_phone",
      :work_phone => "value for work_phone",
      :home_phone => "value for home_phone",
      :work_address => "value for work_address",
      :net_id => "value for net_id",
      :status => "value for status"
    )
  end

  it "renders the edit user form" do
    render

    response.should have_tag("form[action=#{user_path(@user)}][method=post]") do
      with_tag('input#user_first_name[name=?]', "user[first_name]")
      with_tag('input#user_middle_name[name=?]', "user[middle_name]")
      with_tag('input#user_last_name[name=?]', "user[last_name]")
      with_tag('input#user_email[name=?]', "user[email]")
      with_tag('input#user_mobile_phone[name=?]', "user[mobile_phone]")
      with_tag('input#user_work_phone[name=?]', "user[work_phone]")
      with_tag('input#user_home_phone[name=?]', "user[home_phone]")
      with_tag('input#user_work_address[name=?]', "user[work_address]")
      with_tag('input#user_net_id[name=?]', "user[net_id]")
      with_tag('input#user_status[name=?]', "user[status]")
    end
  end
end