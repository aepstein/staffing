require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/users/show.html.erb" do
  include UsersHelper
  before(:each) do
    assigns[:user] = @user = stub_model(User,
      :first_name => "value for first_name",
      :middle_name => "value for middle_name",
      :last_name => "value for last_name",
      :email => "value for email",
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
    response.should have_text(/value\ for\ net_id/)
    response.should have_text(/value\ for\ status/)
  end
end
