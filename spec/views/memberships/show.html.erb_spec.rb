require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/memberships/show.html.erb" do
  include MembershipsHelper
  before(:each) do
    assigns[:membership] = @membership = stub_model(Membership,
      :user => 1,
      :term => 1,
      :position => 1,
      :request => 1
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/1/)
  end
end
