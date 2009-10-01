require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/users/index.html.erb" do
  include UsersHelper

  before(:each) do
    assigns[:users] = [
      stub_model(User,
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
      ),
      stub_model(User,
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
    ]
  end

  it "renders a list of users" do
    render
    response.should have_tag("tr>td", "value for first_name".to_s, 2)
    response.should have_tag("tr>td", "value for middle_name".to_s, 2)
    response.should have_tag("tr>td", "value for last_name".to_s, 2)
    response.should have_tag("tr>td", "value for email".to_s, 2)
    response.should have_tag("tr>td", "value for mobile_phone".to_s, 2)
    response.should have_tag("tr>td", "value for work_phone".to_s, 2)
    response.should have_tag("tr>td", "value for home_phone".to_s, 2)
    response.should have_tag("tr>td", "value for work_address".to_s, 2)
    response.should have_tag("tr>td", "value for net_id".to_s, 2)
    response.should have_tag("tr>td", "value for status".to_s, 2)
  end
end
