require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/users/new.html.erb" do
  include UsersHelper

  before(:each) do
    assigns[:user] = stub_model(User,
      :new_record? => true,
      :first_name => "value for first_name",
      :middle_name => "value for middle_name",
      :last_name => "value for last_name",
      :email => "value for email",
      :net_id => "value for net_id",
      :status => "value for status"
    )
  end

  it "renders new user form" do
    render

    response.should have_tag("form[action=?][method=post]", users_path) do
      with_tag("input#user_first_name[name=?]", "user[first_name]")
      with_tag("input#user_middle_name[name=?]", "user[middle_name]")
      with_tag("input#user_last_name[name=?]", "user[last_name]")
      with_tag("input#user_email[name=?]", "user[email]")
      with_tag("input#user_net_id[name=?]", "user[net_id]")
      with_tag("input#user_status[name=?]", "user[status]")
    end
  end
end
