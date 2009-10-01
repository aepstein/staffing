require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/users/show.html.erb" do
  include UsersHelper
  before(:each) do
    assigns[:user] = @user = stub_model(User,
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

  it "renders attributes in <p>" do
    render
    response.should have_text(/value\ for\ first_name/)
    response.should have_text(/value\ for\ middle_name/)
    response.should have_text(/value\ for\ last_name/)
    response.should have_text(/value\ for\ email/)
    response.should have_text(/value\ for\ mobile_phone/)
    response.should have_text(/value\ for\ work_phone/)
    response.should have_text(/value\ for\ home_phone/)
    response.should have_text(/value\ for\ work_address/)
    response.should have_text(/value\ for\ net_id/)
    response.should have_text(/value\ for\ status/)
  end
end
