require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/memberships/new.html.erb" do
  include MembershipsHelper

  before(:each) do
    assigns[:membership] = stub_model(Membership,
      :new_record? => true,
      :user => 1,
      :term => 1,
      :position => 1,
      :request => 1
    )
  end

  it "renders new membership form" do
    render

    response.should have_tag("form[action=?][method=post]", memberships_path) do
      with_tag("input#membership_user[name=?]", "membership[user]")
      with_tag("input#membership_term[name=?]", "membership[term]")
      with_tag("input#membership_position[name=?]", "membership[position]")
      with_tag("input#membership_request[name=?]", "membership[request]")
    end
  end
end
