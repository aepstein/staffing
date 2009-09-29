require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/memberships/index.html.erb" do
  include MembershipsHelper

  before(:each) do
    assigns[:memberships] = [
      stub_model(Membership,
        :user => 1,
        :term => 1,
        :position => 1,
        :request => 1
      ),
      stub_model(Membership,
        :user => 1,
        :term => 1,
        :position => 1,
        :request => 1
      )
    ]
  end

  it "renders a list of memberships" do
    render
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
  end
end
